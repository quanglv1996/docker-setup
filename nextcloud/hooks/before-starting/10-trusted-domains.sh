#!/bin/sh
# Đồng bộ trusted_domains từ NEXTCLOUD_TRUSTED_DOMAINS mỗi lần khởi động
# (image gốc chỉ áp dụng biến này ở lần cài đặt đầu tiên).
set -e

[ -n "$NEXTCLOUD_TRUSTED_DOMAINS" ] || exit 0

php /var/www/html/occ config:system:delete trusted_domains
i=0
for domain in $NEXTCLOUD_TRUSTED_DOMAINS; do
  php /var/www/html/occ config:system:set trusted_domains "$i" --value="$domain"
  i=$((i + 1))
done
