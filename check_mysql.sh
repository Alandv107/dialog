#!/bin/bash 
 
DB_HOST="" 
DB_USER="alan" 
DB_PASS="" 
DB_NAME="KOL_ALAN" 
TEMP_FILE="query_result.txt" 
 
echo "開始選擇平台..."
platform=$(dialog --stdout --menu "選擇要檢查的平台" 15 50 3 \
    "instagram" "Instagram" \
    "tiktok" "TikTok" \
    "youtube" "YouTube") 
 
if [ -z "$platform" ]; then 
    dialog --msgbox "未選擇任何平台，程式結束。" 8 40 
    exit 1 
fi 
 
if [ "$platform" = "instagram" ]; then
    table="instagram_reels" 
    columns="username, reel_index, views, link" 
    filter_field="reel_index" 
    filter_label="Reels 編號" 
elif [ "$platform" = "tiktok" ]; then
    table="tiktok_videos" 
    columns="username, video_number, views, url, likes, comments, saves, shares" 
    filter_field="video_id" 
    filter_label="影片 ID" 
elif [ "$platform" = "youtube" ]; then
    table="youtube_videos" 
    columns="channel_name, video_id, views, likes, comments" 
    filter_field="video_id" 
    filter_label="影片 ID" 
else
    dialog --msgbox "⚠️ 錯誤：無效的平台選擇！" 8 40 
    exit 1 
fi
 
filter_value=$(dialog --stdout --inputbox "請輸入要查詢的 ${filter_label}（留空則顯示最新 10 筆）" 8 50) 
 
filter_condition="" 
if [ -n "$filter_value" ]; then 
    filter_condition="WHERE ${filter_field} = '$filter_value'" 
fi 
 
dialog --yesno "是否查詢 ${table} 的資料？" 8 40 
answer=$?
if [ $answer -ne 0 ]; then 
    dialog --msgbox "查詢已取消。" 8 40 
    exit 0 
fi 

echo "執行查詢中..."
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" --default-character-set=utf8mb4 -e " 
SELECT ${columns} FROM ${table} ${filter_condition} LIMIT 10;" > "$TEMP_FILE" 
 
if [ ! -s "$TEMP_FILE" ]; then 
    dialog --msgbox "⚠️ 沒有找到 ${platform} 的資料！請確認資料是否已匯入。" 8 50 
    rm -f "$TEMP_FILE" 
    exit 1 
fi 
 
dialog --textbox "$TEMP_FILE" 20 80 
dialog --msgbox "✅ 查詢完成！" 8 40 
 
rm -f "$TEMP_FILE"
echo "程式結束"