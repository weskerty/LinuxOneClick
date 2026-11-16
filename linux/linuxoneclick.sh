#!/bin/bash
# LinuxOneClick - se ejecuta en cada arranque (linuxoneclick.service).
# Instalar en la imagen como /usr/local/sbin/linuxoneclick (chmod 755).
#
#  1) Una sola vez: apunta /boot/efi a la ESP real (la que tiene EFI/*/linuxoneclick.txt,
#     que escribe Instalar-Linux.ps1).
#  2) Siempre: arranque predeterminado segun el marcador (por_defecto=linux|windows) y BitLocker:
#       - linux:   GRUB primero en el firmware, menu con Windows (os-prober).
#       - windows: Windows primero; GRUB no se pone primero al actualizarse (update_nvram=false).
#       - seguro:  si alguna particion esta cifrada con BitLocker: Windows primero y Windows FUERA
#                  del menu de GRUB. Arrancar Windows desde GRUB cambia lo que mide el TPM y
#                  BitLocker pide la clave de recuperacion. A Windows se vuelve con el lanzador
#                  "Reiniciar en Windows" (efibootmgr -n: el firmware arranca Windows directo).
#     Si una actualizacion de Windows o del firmware cambia el orden, se vuelve a acomodar.
#  3) Siempre: si hay >= 1 GiB sin particionar pegado a una particion de este btrfs, lo suma:
#       - hueco DESPUES de la particion -> agranda la particion y "btrfs filesystem resize max"
#       - hueco ANTES (lo normal tras achicar C:) -> particion nueva + "btrfs device add"
#     Los huecos que no tocan a Linux no se usan.
#     Ademas, si el btrfs ocupa menos que su particion (primer arranque tras instalar), lo agranda.
#
# Sin marcador en ninguna ESP (por ejemplo en la VM) no hace nada.
#
# Uso: linuxoneclick [--forzar] [--simular] [--montaje DIR]
#      linuxoneclick --reiniciar-windows
#   --forzar             hace el paso 3 aunque no haya marcador (pruebas). Nunca toca la ESP ni el arranque.
#   --simular            muestra lo que haria, sin cambiar nada.
#   --montaje            btrfs sobre el que trabajar (por defecto /).
#   --reiniciar-windows  el proximo arranque va directo a Windows (sin GRUB) y reinicia.

set -u
export LC_ALL=C
ESTADO=/var/lib/linuxoneclick
TIPO_ESP=c12a7328-f81f-11d2-ba4b-00a0c93ec93b
TIPO_LINUX=0FC63DAF-8483-4772-8E79-3D69D8477DE4
MINIMO=$((1024 * 1024 * 1024))     # 1 GiB
ALINEAR=$((1024 * 1024))           # 1 MiB
CFG_GRUB=/etc/default/grub.d/99-linuxoneclick.cfg
LANZADOR=/usr/share/applications/linuxoneclick-windows.desktop
WINDOWS_EFI='\EFI\Microsoft\Boot\bootmgfw.efi'

FORZAR=0; SIMULAR=0; MONTAJE=/; REINICIAR_WIN=0
while [ $# -gt 0 ]; do
    case "$1" in
        --forzar)            FORZAR=1 ;;
        --simular)           SIMULAR=1 ;;
        --montaje)           MONTAJE=${2:?falta DIR}; shift ;;
        --reiniciar-windows) REINICIAR_WIN=1 ;;
        *) echo "opcion desconocida: $1" >&2; exit 2 ;;
    esac
    shift
done

log()   { echo "linuxoneclick: $*"; }
hacer() {
    if [ "$SIMULAR" = 1 ]; then log "[simular] $*"; return 0; fi
    log "+ $*"; "$@"
}

# ---------------------------------------------------------------- firmware (efibootmgr)
# Numeros BootXXXX (solo los 4 hex) de las entradas cuyo camino contiene el texto dado.
entradas_con() {
    efibootmgr -v 2>/dev/null | grep -iF -- "$1" | grep -o '^Boot[0-9A-Fa-f]\{4\}' | cut -c5-
}

reiniciar_windows() {
    local win
    win=$(entradas_con "$WINDOWS_EFI" | head -n1)
    [ -n "$win" ] || { log "no se encuentra Windows Boot Manager en el firmware"; return 1; }
    efibootmgr -q -n "$win" && systemctl reboot
}

if [ "$REINICIAR_WIN" = 1 ]; then
    reiniciar_windows
    exit $?
fi

# ---------------------------------------------------------------- marcador en la ESP
ESP=""; CONF=""; EFIDIR=""
buscar_marcador() {
    local tmp dev m
    tmp=$(mktemp -d)
    for dev in $(lsblk -rnpo NAME,PARTTYPE | awk -v t="$TIPO_ESP" 'tolower($2)==t {print $1}'); do
        if mount -o ro "$dev" "$tmp" 2>/dev/null; then
            for m in "$tmp"/EFI/*/linuxoneclick.txt; do
                [ -f "$m" ] && { ESP=$dev; CONF=$(cat "$m"); EFIDIR=$(basename "$(dirname "$m")"); }
            done
            umount "$tmp"
        fi
        [ -n "$ESP" ] && break
    done
    rmdir "$tmp"
}

# ---------------------------------------------------------------- 1) ESP real (una vez)
corregir_esp() {
    [ -e "$ESTADO/esp-hecho" ] && return 0
    local uuid
    uuid=$(blkid -s UUID -o value "$ESP")
    [ -n "$uuid" ] || { log "la ESP $ESP no tiene UUID"; return 1; }
    log "ESP real: $ESP ($uuid)"

    if [ "$SIMULAR" = 1 ]; then log "[simular] fstab: /boot/efi -> UUID=$uuid"; return 0; fi

    mountpoint -q /boot/efi && umount /boot/efi
    sed -i '\|[[:space:]]/boot/efi[[:space:]]|d' /etc/fstab
    echo "UUID=$uuid  /boot/efi  vfat   umask=0077,nofail,x-systemd.device-timeout=5s   0  1" >> /etc/fstab
    systemctl daemon-reload
    mkdir -p /boot/efi
    if mount /boot/efi; then
        mkdir -p "$ESTADO"
        touch "$ESTADO/esp-hecho"
    else
        log "no se pudo montar /boot/efi; se reintenta en el proximo arranque"
    fi
}

# ---------------------------------------------------------------- 2) arranque predeterminado
# Pone primero en BootOrder la entrada pedida (linux = la nuestra, windows = Windows Boot Manager).
orden_arranque() {
    local quiero=$1 salida orden primero nuestras win elegido resto b
    command -v efibootmgr >/dev/null || { log "falta efibootmgr"; return 0; }
    salida=$(efibootmgr -v 2>/dev/null) || { log "efibootmgr no puede leer el firmware"; return 0; }
    orden=$(printf '%s\n' "$salida" | sed -n 's/^BootOrder: *//p')
    [ -n "$orden" ] || return 0
    nuestras=$(entradas_con "\\EFI\\$EFIDIR\\")
    win=$(entradas_con "$WINDOWS_EFI" | head -n1)
    [ -n "$nuestras" ] || { log "no hay entrada de firmware de Linux (\\EFI\\$EFIDIR\\)"; return 0; }
    primero=${orden%%,*}

    if [ "$quiero" = linux ]; then
        printf '%s\n' $nuestras | grep -qix -- "$primero" && return 0
        elegido=""
        for b in $(printf '%s\n' "$orden" | tr ',' ' '); do
            printf '%s\n' $nuestras | grep -qix -- "$b" && { elegido=$b; break; }
        done
        [ -n "$elegido" ] || elegido=$(printf '%s\n' $nuestras | head -n1)
    else
        [ -n "$win" ] || return 0
        [ "${primero^^}" = "${win^^}" ] && return 0
        # Solo si lo que esta primero es Linux; algo ajeno (USB, red) no se toca.
        printf '%s\n' $nuestras | grep -qix -- "$primero" || return 0
        elegido=$win
    fi
    resto=$(printf '%s\n' "$orden" | tr ',' '\n' | grep -vix -- "$elegido" | paste -sd, -)
    log "orden de arranque: $orden -> $elegido${resto:+,$resto}"
    hacer efibootmgr -q -o "$elegido${resto:+,$resto}"
}

revisar_arranque() {
    local pd modo anterior prober estilo espera nvram cfg
    pd=$(printf '%s\n' "$CONF" | sed -n 's/^por_defecto=//p' | head -n1)
    if lsblk -rno FSTYPE 2>/dev/null | grep -qix bitlocker; then
        modo=seguro
    elif [ "$pd" = linux ]; then
        modo=linux
    else
        modo=windows
    fi
    case $modo in
        linux)   prober=false; estilo=menu;   espera=5; nvram=true  ;;
        windows) prober=false; estilo=menu;   espera=5; nvram=false ;;
        seguro)  prober=true;  estilo=hidden; espera=0; nvram=false ;;
    esac
    cfg=$(printf '# LinuxOneClick (modo %s): lo reescribe linuxoneclick.service en cada arranque\nGRUB_DISABLE_OS_PROBER=%s\nGRUB_TIMEOUT_STYLE=%s\nGRUB_TIMEOUT=%s' \
          "$modo" "$prober" "$estilo" "$espera")

    anterior=$(cat "$ESTADO/modo" 2>/dev/null || true)
    [ "$anterior" = "$modo" ] || log "modo de arranque: ${anterior:-ninguno} -> $modo"
    if [ "$SIMULAR" = 1 ]; then log "[simular] modo $modo; update_nvram=$nvram"; orden_arranque "$([ $modo = linux ] && echo linux || echo windows)"; return 0; fi

    mkdir -p "$ESTADO" /etc/default/grub.d
    if [ "$anterior" != "$modo" ]; then
        # En Mint 22.x la pregunta es de grub-pc (su postinst tambien hace el grub-install EFI).
        echo "grub-pc grub2/update_nvram boolean $nvram" | debconf-set-selections || log "no se pudo ajustar update_nvram"
    fi
    if [ "$(cat "$CFG_GRUB" 2>/dev/null)" != "$cfg" ] || [ ! -e "$ESTADO/grub-hecho" ]; then
        rm -f "$ESTADO/grub-hecho"
        printf '%s\n' "$cfg" > "$CFG_GRUB"
        if update-grub; then touch "$ESTADO/grub-hecho"; else log "update-grub fallo; se reintenta en el proximo arranque"; fi
    fi
    echo "$modo" > "$ESTADO/modo"

    if [ "$modo" = linux ]; then orden_arranque linux; else orden_arranque windows; fi
}

# Lanzador en el menu: "Reiniciar en Windows" sin pasar por GRUB.
instalar_lanzador() {
    local contenido
    contenido='[Desktop Entry]
Type=Application
Name=Restart into Windows
Name[es]=Reiniciar en Windows
Comment=Restart the PC directly into Windows
Comment[es]=Reinicia la PC directo en Windows
Icon=system-reboot
Exec=pkexec /usr/local/sbin/linuxoneclick --reiniciar-windows
Terminal=false
Categories=System;'
    [ "$(cat "$LANZADOR" 2>/dev/null)" = "$contenido" ] && return 0
    [ "$SIMULAR" = 1 ] && { log "[simular] lanzador $LANZADOR"; return 0; }
    printf '%s\n' "$contenido" > "$LANZADOR"
    log "lanzador creado: $LANZADOR"
}

# ---------------------------------------------------------------- 3) espacio libre
disco_de() { echo "/dev/$(lsblk -no PKNAME "$1" | head -n1)"; }

# Imprime la primera accion posible en el disco, o nada:
#   crecer <particion>          hueco >= 1 GiB justo despues de una particion nuestra
#   nueva  <inicio> <fin>       hueco >= 1 GiB justo antes de una particion nuestra (en sectores)
buscar_hueco() {
    local disco=$1 nuestras=$2 ss
    ss=$(cat "/sys/block/$(basename "$disco")/queue/logical_block_size")
    sfdisk -d "$disco" 2>/dev/null | awk -v ss="$ss" -v min="$MINIMO" -v nuestras="$nuestras" '
        BEGIN { n = split(nuestras, a, /[ \n]+/); for (i = 1; i <= n; i++) if (a[i] != "") mia[a[i]] = 1
                min = int(min / ss) }
        /^label:/     { label = $2 }
        /^first-lba:/ { first = $2 + 0 }
        /^last-lba:/  { last = $2 + 0 }
        /^\/dev\// {
            s = $0; sub(/.*start= */, "", s); sub(/[^0-9].*/, "", s)
            z = $0; sub(/.*size= */, "", z);  sub(/[^0-9].*/, "", z)
            np++; ps[np] = s + 0; pz[np] = z + 0; pn[np] = $1
        }
        END {
            if (label != "gpt" || np == 0) exit
            for (i = 2; i <= np; i++)
                for (j = i; j > 1 && ps[j-1] > ps[j]; j--) {
                    t = ps[j]; ps[j] = ps[j-1]; ps[j-1] = t
                    t = pz[j]; pz[j] = pz[j-1]; pz[j-1] = t
                    t = pn[j]; pn[j] = pn[j-1]; pn[j-1] = t
                }
            fin = first - 1; ant = ""
            for (i = 1; i <= np + 1; i++) {
                gs = fin + 1
                if (i <= np) { ge = ps[i] - 1; sig = pn[i] } else { ge = last; sig = "" }
                if (ge - gs + 1 >= min) {
                    if (ant != "" && (ant in mia)) { print "crecer", ant; exit }
                    if (sig != "" && (sig in mia)) { print "nueva", gs, ge; exit }
                }
                if (i <= np) { if (ps[i] + pz[i] - 1 > fin) fin = ps[i] + pz[i] - 1; ant = pn[i] }
            }
        }'
}

devid_de() {   # devid de una particion dentro del btrfs montado
    btrfs filesystem show --raw "$MONTAJE" | awk -v p="$1" '$1 == "devid" && $NF == p {print $2}'
}

esperar_nodo() {
    local i
    for i in $(seq 1 20); do [ -b "$1" ] && return 0; udevadm settle; sleep 0.25; done
    return 1
}

crecer() {
    local part=$1 disco num devid
    disco=$(disco_de "$part"); num=$(cat "/sys/class/block/$(basename "$part")/partition")
    log "hueco libre despues de $part: se agranda"
    [ "$SIMULAR" = 1 ] && { log "[simular] sfdisk -N $num $disco (', +'); btrfs filesystem resize max"; return 0; }
    echo ', +' | sfdisk -q --no-reread --no-tell-kernel -N "$num" "$disco" || return 1
    partx -u --nr "$num" "$disco" || return 1
    udevadm settle
    devid=$(devid_de "$part")
    [ -n "$devid" ] || { log "no encuentro el devid de $part"; return 1; }
    hacer btrfs filesystem resize "$devid:max" "$MONTAJE"
}

nueva() {
    local disco=$1 gs=$2 ge=$3 ss al ini tam nodo num
    ss=$(cat "/sys/block/$(basename "$disco")/queue/logical_block_size")
    al=$((ALINEAR / ss))
    ini=$(( (gs + al - 1) / al * al ))
    tam=$(( (ge - ini + 1) / al * al ))
    [ $((tam * ss)) -ge "$MINIMO" ] || { log "el hueco alineado queda chico; se ignora"; return 1; }
    log "hueco libre antes de Linux en $disco: particion nueva de $((tam * ss / 1048576)) MiB"
    [ "$SIMULAR" = 1 ] && { log "[simular] sfdisk --append start=$ini size=$tam; btrfs device add"; return 0; }

    echo "start=$ini, size=$tam, type=$TIPO_LINUX, name=\"LinuxOneClick\"" |
        sfdisk -q --no-reread --no-tell-kernel --append "$disco" || return 1
    nodo=$(sfdisk -d "$disco" | awk -v s="$ini" '/^\/dev\// { x = $0; sub(/.*start= */, "", x); sub(/[^0-9].*/, "", x); if (x + 0 == s) print $1 }')
    [ -n "$nodo" ] || { log "no encuentro la particion recien creada"; return 1; }
    num=${nodo##*[!0-9]}
    partx -a --nr "$num" "$disco" || return 1
    esperar_nodo "$nodo" || { log "no aparecio $nodo"; return 1; }
    wipefs -a "$nodo" >/dev/null
    hacer btrfs device add -f "$nodo" "$MONTAJE"
}

agregar_espacio() {
    local fsuuid nuestras disco accion vuelta hubo
    [ "$(findmnt -no FSTYPE "$MONTAJE")" = btrfs ] || { log "$MONTAJE no es btrfs; no se agrega espacio"; return 0; }
    fsuuid=$(findmnt -no UUID "$MONTAJE")
    for vuelta in 1 2 3 4 5 6 7 8; do
        udevadm settle
        nuestras=$(lsblk -rnpo NAME,UUID | awk -v u="$fsuuid" '$2 == u {print $1}')
        [ -n "$nuestras" ] || { log "no encuentro las particiones del btrfs $fsuuid"; return 1; }
        hubo=0
        for disco in $(for p in $nuestras; do disco_de "$p"; done | sort -u); do
            accion=$(buscar_hueco "$disco" "$nuestras")
            [ -n "$accion" ] || continue
            set -- $accion
            case "$1" in
                crecer) crecer "$2" || return 1 ;;
                nueva)  nueva "$disco" "$2" "$3" || return 1 ;;
            esac
            hubo=1; break
        done
        [ "$hubo" = 1 ] && [ "$SIMULAR" = 0 ] || break
    done
    [ "$vuelta" = 1 ] && [ "$hubo" = 0 ] && log "sin espacio libre para sumar"
    ajustar_tamanos
    return 0
}

# Si el btrfs ocupa menos que su particion (el instalador copia una imagen de ~25 GB en una
# particion mas grande), lo lleva al maximo. Si ya ocupa todo, no hace nada.
ajustar_tamanos() {
    local devid tam ruta part
    btrfs filesystem show --raw "$MONTAJE" | awk '$1 == "devid" {print $2, $4, $NF}' |
    while read -r devid tam ruta; do
        part=$(blockdev --getsize64 "$ruta" 2>/dev/null) || continue
        if [ $((part - tam)) -ge "$ALINEAR" ]; then
            log "$ruta: el btrfs usa $((tam / 1048576)) MiB de $((part / 1048576)) MiB"
            hacer btrfs filesystem resize "$devid:max" "$MONTAJE"
        fi
    done
}

# ---------------------------------------------------------------- principal
udevadm settle || true
buscar_marcador
if [ -n "$ESP" ]; then
    corregir_esp
    revisar_arranque
    instalar_lanzador
elif [ "$FORZAR" = 0 ]; then
    log "no hay marcador de LinuxOneClick en ninguna ESP (VM?); no se hace nada"
    exit 0
fi
agregar_espacio
