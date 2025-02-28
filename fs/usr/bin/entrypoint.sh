#!/command/with-contenv sh
PUID=${PUID:-9393}
PGID=${PGID:-"$PUID"}
PUSER=${PUSER:-user}
PGROUP=${PGROUP:-"$PUSER"}
HOME_DIR=$(getent passwd $PUSER | cut -d: -f6)
exec s6-setuidgid "$PUSER" sh -c "export HOME=$HOME_DIR; $@"
