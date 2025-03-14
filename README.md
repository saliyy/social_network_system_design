# social_network_system_design

Functional requirements:
 - publishing travel posts with photos, a short description and a link to a specific place of travel
 - rating and comments of other travelers' posts
 - Subscribe to other travelers to keep track of their activity
 - Search for popular travel destinations and view posts from those locations
 - View other travelers' feeds and user feeds based on subscriptions in reverse chronological order


# Non-functional requirements:
 - 10 000 000 DAU
 - availability 99,95%
 - Geo within the CIS countries
 - Data is stored permanently
 - 
- Seasonality. Usage spikes expected during peak travel/holiday seasons (e.g., summer vacations, winter holidays), with a possible **30-40% increase** in daily activity (posts, comments, feed views). The system must handle these peaks while maintaining performance and availability targets
- 
# Limits:
 - Post Text Body max 2000 symb
 - Max 5 images per post
 - Max size of image 2MB
 - Max 1kk followers 
# Medium User Activites:
 - publish 2 post per week
 - view feeds 3 times per day, each feed request loads ~15 posts
 - 1 comment per day
 - 2 fetches to comment list, (10 comment's per fetch)
 - makes 1 sub per day
 - makes 5 reactions per day
 - 2 search for travel destinations per week, ~10 post per search result

# Basic calculations

### Post: 
 - body + title + link + other ~= 20 KB
 - Images ~= 3 image per post * 500KB ~= 2MB

 ### Places: 
 - body + title + link + other ~= 20 KB
 - Images ~= 3 image per post * 500KB ~= 2MB

### Comment:
- body ~= 10KB
- images ~= 1MB

### Reaction:
  - body ~= 500B
    
### Sub:
  - body ~= 500B

### Search for travel destination:
  - body ~= 1KB

# Publish Post:
PRS (Write) 10 000 000 * 2 / 7 / 86 400 ~= 30 RPS
Traffic (Write):
  Text: 30 RPS * 20KB (post body) ~= 600KB/s (text body)
  Media: 30 RPS * + 2000KB (media) ~= 60 MB/s media

# Read Posts RPS (Read):
RPS (Read) = 10 000 000 * 3 feeds / 86 400 = ~= 350 RPS
Traffic (Read): 
   Text: 350 PRS * 20KB (text body) * 15 posts ~= 100 MB/s text & 
   Media: 350 PRS * 2000KB (media)  * 15 posts ~= 10 GB/s media

# Make comment RPS (Write)
10 000 000 * 1 comment per day / 86 400 ~= 150 RPS
Traffic (Read):
  Text: 150 RPS * 10 KB = 1,500 KB/s = 1.5 MB/s text 
  Media: ~= 150MB 
  
# Read comments RPS (Read)
10 000 000 * 2 comment fetches / 86 400 ~= 250 RPS
Traffic (Read):
  Text:  250 RPS * 10KB * 10 per comments fetch *  ~= 25MB text 
  Media: 250 PRS * 1000KB media * 10 comments per fetch ~= 3GB/s media

# Make sub RPS (Write)
10 000 000 * 1 sub per day / 86 400 ~= 150 RPS
Traffic (Write)
  Text: ~= 73KB/s 

# Make reactions (Write)
10 000 000 * 5 reactions / 86 000 ~= 550 RPS
Traffic (Write)
  Text: ~= 268KB/s

# Search for travel destinations per week (Read)
10 000 000 * 2 / 7 / 86 400 ~= 30 RPS
Traffic (Read)
  Text: 30 RPS * 20KB text body * 10 places ~= 6Mb text
  Media: 30 RPS * 2000KB media * 10 places ~= 600MB media


#### DISK evaluation per one year:

Posts:
  Meta:
    capacity: 600KB/s * 86400 * 365 ~= 24000000000KB ~= 24TB 
    traffic_per_sec(RW): 100MB
    iops(RW): ceil(350 + 30) = 400

      HDD:
        Disks_for_capacity: 24TB / 32TB = 1 disks (c запасом)
        Disks_for_throughput: 100MB / 100MB = 2 disks (на случай пропускать больше на 15-20%)
        Disks_for_iops: 400 / 100 = 4 disks
        Total: max(ceil(1.5), ceil(2), ceil(4)) = 4
      
      SSD(SATA):
        Disks_for_capacity: 24TB / 100TB = 1 disk
        Disks_for_throughput: 100MB / 500MB = 1 disk
        Disks_for_iops: 400 / 1000 = 1 disk
        Total: max(ceil(1), ceil(1), ceil(1)) = 4 disks по 6 ТБ

      SSD(nVME):
        Disks_for_capacity: 24TB / 30 = 1.3 disks
        Disks_for_throughput: 100MB / 3GB/sec = 1 disk 
        Disks_for_iops: 400 / 10_000 = 1 disk
        Total: max(ceil(1.3), ceil(1), ceil(1)) = 2
    Summary: 
      - Можно выбрать SSD(SATA) 4 диска по 6 ТБ, старые посты сгружать на HDD
    Hosts: 
     - 4 disks by 6 TB, т.к у нас read intensive app, мы можем мастшабироваться через реплики.
        Hosts = 4 disk / 1 disk by host = 4 
        Replicas: 4 hosts с RF 2 = 8 hosts
    Sharding:
     - hash partitioning для user_id, данные для одного пользователя будем писать в один шард и читать из одного шарда, тут есть проблема в ассимтричной нагрузке если какой-то из юзеров будет сильно популярен, тогда вероятно нужно будет бить данные для одного пользователя на разные шарды на стороне приложения/coordinator

  Media: 
    capacity: 60 MB/s * 86400 * 365 ~= 2,4PB
    traffic_per_sec(RW): 10GB/s
    iops(RW): ceil(350 + 30) = 400

      HDD:
        Disks_for_capacity: 2.4PB / 32TB ~= 75 disks
        Disks_for_throughput: 10GB/s / 100MB/s = 100 disks
        Disks_for_iops: 400 / 100 = 4 disks
        Total: max(ceil(75), ceil(100), ceil(4)) = 100

      SSD(SATA):
       Disks_for_capacity: 2.4BP / 100TB ~= 24 disks (если каждый диск будет по 100ТБ)
       Disks_for_throughput: 10GB/s / 500MB/s = 20 disks
       Disks_for_iops: 400 / 1000 = 0,4 => 1 disk
       Total: max(ceil(24), ceil(20), ceil(1)) = 24

      SSD(nVME):
       Disks_for_capacity: 2.4PB / 30TB = 80 disks (каждый диск по 30ТБ)
       Disks_for_throughput: 10GB/s / 3GB/s = 4 disks
       Disks_for_iops: 400 / 10_000 = 0,4 = 1 disk
       Total: max(ceil(80), ceil(4), ceil(1)) = 80
  Summary:
    Взять 20-30 SSD(nVME) и 70-80 HDD
    Hosts: 
     - 100 disks в общем, т.к у нас read intensive app, мы можем мастшабироваться через реплики.
        Hosts = 100 disk / 4 disk by host = 25
        Replicas: 25 hosts с RF 2 = 50 hosts
    Sharding:
     - hash partitioning для (image_id, image_type), данные для одного поста/комментария/etc будем писать в один шард и читать из одного шарда

Comments:
  Meta:
    capacity: 1.5 MB/s text * 86400 * 365 ~= 47.3TB
    traffic_per_sec(RW): 27MB/s
    iops(RW): 250 + 150 = 400

      HDD:
        Disks_for_capacity: 47.3TB / 32TB = 2 disks (c запасом)
        Disks_for_throughput: 27MB/s / 100MB = 1 disks
        Disks_for_iops: 400 / 100 = 4 disks
        Total: max(ceil(1.5), ceil(2), ceil(4)) = 4
      
      SSD(SATA):
        Disks_for_capacity: 47.3TB / 100TB = 1 disk 
        Disks_for_throughput: 27MB/s / 500MB = 1 disk
        Disks_for_iops: 400 / 1000 = 1 disk
        Total: max(ceil(1), ceil(1), ceil(1)) = 1

      SSD(nVME):
        Disks_for_capacity: 47.3TB / 30 = 2 disks (c запасом)
        Disks_for_throughput: 27MB/s / 3GB/sec = 1 disk 
        Disks_for_iops: 400 / 10_000 = 1 disk
        Total: max(ceil(1.3), ceil(1), ceil(1)) = 2
    Summary: 
      - Можно выбрать SSD(SATA) 4 диска по 6 ТБ, старые комменты сгружать на HDD
    Hosts: 
     - 4 disks by 6 TB, в случае подсистемы комментариев у нас чаще скорее пишут чем читают.
        Hosts = 4 disk / 1 disk by host = 4 
        Replicas: 4 hosts с RF 2 = 8 hosts
    Sharding:
     - hash partitioning для post_id, данные для одного поста будем писать в один шард и читать из одного шарда, тут есть проблема в ассимтричной нагрузке если какой-то из постов будет сильно популярен, тогда вероятно нужно будет бить данные для одного пользователя на разные шарды на стороне приложения/coordinator

  Media: 
    capacity: 150MB  * 86400 * 365 ~= 4,5PB
    traffic_per_sec(RW): 3,5GB/s
    iops(RW): 250 + 150 = 400

      HDD:
        Disks_for_capacity: 4,5PB / 32TB = 144 disks
        Disks_for_throughput: 3,5GB/s / 100MB/s = 35 disks
        Disks_for_iops: 400 / 100 = 4 disks
        Total: max(ceil(75), ceil(100), ceil(4)) = 144

      SSD(SATA):
       Disks_for_capacity: 4,5PB / 100TB ~= 46 disks
       Disks_for_throughput: 3,5GB/s / 500MB/s = 15 disks
       Disks_for_iops: 400 / 1000 = 0,4 => 1 disk
       Total: max(ceil(24), ceil(20), ceil(1)) = 46

      SSD(nVME):
       Disks_for_capacity: 4,5PB / 30TB ~= 150 disks
       Disks_for_throughput: 3,5GB/s / 3GB/s = 1.5 disks
       Disks_for_iops: 400 / 10_000 = 0,4 = 1 disk
       Total: max(ceil(80), ceil(4), ceil(1)) = 150
  Summary:
    SSD(SATA): 20 дисков по 12 ТБ на горячие данные
    HDD: 100-120 дисков на холодные
  Hosts: 
     - 120 disks, в случае подсистемы комментариев у нас чаще скорее пишут чем читают.
      Hosts = 120 disk / 4 disk by host = 30 hosts
      Replicas: 30 hosts с RF 2 = 60 hosts
    Sharding:
     - hash partitioning для post_id, данные для одного поста будем писать в один шард и читать из одного шарда, тут есть проблема в ассимтричной нагрузке если какой-то из постов будет сильно популярен, тогда вероятно нужно будет бить данные для одного пользователя на разные шарды на стороне приложения/coordinator


Для реакций/подписок не стал расписывать, возьмем по 1 диску SSD, т.к там в основном высокий IOPs, не нужна высокая пропускная способность и маленький capacity. 