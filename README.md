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
  Text: 30 RPS * 20KB text body * 10 posts ~= 6Mb text
  Media: 30 RPS * 2000KB media * 10 posts ~= 600MB media
