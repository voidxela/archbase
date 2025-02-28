#!/command/with-contenv bash
[[ "$PUSER" == "admin" ]] && exit 0
PUID=${PUID:-9393}
PGID=${PGID:-"$PUID"}
PUSER=${PUSER:-user}
PGROUP=${PGROUP:-"$PUSER"}
groupadd -g $PGID $GROUP 2>/dev/null || groupmod -o -g "$PGID" "$PGROUP"
id -u "$PUSER" &>/dev/null || useradd -u "$PUID" -g "$PGID" -s /bin/bash -m "$PUSER"
chown -R "$PUSER":"$PGROUP" /app
chmod -R g+w /app
