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

### Comment:
- body ~= 10KB
- images ~= 1MB

### Reaction:
  - body ~= 500B
    
### Sub:
  - body ~= 500B

### Search for travel destination:
  - body ~= 1KB

Publish Post:
PRS (Write) =
[ \frac{10{,}000{,}000 \times 2}{7 \times 86{,}400} \approx 30 , \text{RPS} ]
Traffic:
Text:
[ 30 , \text{RPS} \times 20 , \text{KB (тело поста)} \approx 600 , \text{KB/s (текст)} ]
Media:
[ 30 , \text{RPS} \times 2000 , \text{KB (медиа)} \approx 60 , \text{MB/s (медиа)} ]

Read Posts RPS (Read):
RPS =
[ \frac{10{,}000{,}000 \times 3 \text{ поста}}{86{,}400} \approx 350 , \text{RPS} ]
Traffic:
Text:
[ 350 , \text{RPS} \times 20 , \text{KB (тело поста)} \approx 7000 , \text{KB/s (текст)} ]
Media:
[ 350 , \text{RPS} \times 2000 , \text{KB (медиа)} \times 15 \approx 10 , \text{GB/s (медиа)} ]

Make Comment RPS (Write):
RPS =
[ \frac{10{,}000{,}000 \times 1 \text{ комментарий в день}}{86{,}400} \approx 150 , \text{RPS} ]
Traffic:
Text:
[ 150 , \text{RPS} \times 10 , \text{KB} \approx 1{,}500 , \text{KB/s} = 1.5 , \text{MB/s (текст)} ]
Media:
[ \approx 150 , \text{MB (медиа)} ]

Read Comments RPS (Read):
RPS =
[ \frac{10{,}000{,}000 \times 2 \text{ получения комментариев}}{86{,}400} \approx 250 , \text{RPS} ]
Traffic:
Text:
[ 250 , \text{RPS} \times 10 , \text{KB} \times 10 \approx 25{,}000 , \text{KB/s} = 25 , \text{MB/s (текст)} ]
Media:
[ 250 , \text{RPS} \times 1000 , \text{KB (медиа)} \approx 250{,}000 , \text{KB/s} = \approx 3 , \text{GB/s (медиа)} ]

Make Sub RPS (Write):
RPS =
[ \frac{10{,}000{,}000 \times 1 \text{ подписка в день}}{86{,}400} \approx 150 , \text{RPS} ]
Traffic:

≈
73
 
KB/s (текст)
Make Reactions (Write):
RPS =
[ \frac{10{,}000{,}000 \times 5 \text{ реакций}}{86{,}000} \approx 550 , \text{RPS} ]
Traffic:

≈
268
 
KB/s (текст)
Search for Travel Destinations per Week (Read):
RPS =
[ \frac{10{,}000{,}000 \times 2}{7 \times 86{,}400} \approx 30 , \text{RPS} ]
Traffic:
Text:
[ 30 , \text{RPS} \times (20 , \text{KB (тело текста)} + 2000 , \text{KB (медиа)}) \times 10 , \text{постов} \approx 6 , \text{MB (текст)} ]
Media:
[ \approx 600 , \text{MB (медиа)} ]
