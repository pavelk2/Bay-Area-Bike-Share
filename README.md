BAY AREA BIKE SHARE PROGRAM
===========================

------------------------------------------------------------------------

1. The Scope Of The Analysis
----------------------------

#### Unbalanced stations

Bike sharing programs usually have a problem of **unbalanced stations** where the **number of trips from** these stations is **higher** than the number of **trips to** these stations (or vice versa). Because of this issue there is a need to transfer bicycles using trucks between stations.

#### Not uniform usage of bicycles

Some stations are very popular with many rents, while some have only few rents. Because of that in general bicycles at popular stations tend to be used significantly more often than bicycles at not popular stations. A not uniform usage of bicycles leads to a need of bringing heavily used bicycles often to a workshop, while there are some bicycles almost new and used only a few times.

The goal is to analyse the data and see if there is a possibility to suggest bicycle transfers in a way to balance bicycle usage.

2. Dataset overview
-------------------

We download the dataset for September 2014 - August 2015 from <http://www.bayareabikeshare.com/open-data>. The zip file contains several files. In this analysis we are specifically interested in: 201508\_trip\_data.csv, 201508\_station\_data.csv. The structure of these datasets could be found in README.txt file.

### 2.1 Usage by time

Riders who purchased 1-3 days passes are called *Customers*. *Subscribers* are the riders who purchased an annual pass. These two types of users show different behavior in using the system.

#### Subscribers vs Customers | Weekday vs Weekend

![](2.Analysis_files/figure-markdown_github/unnamed-chunk-3-1.png)

During weekdays Subscribers use the service for commuting purpuses with peaks at 8AM and 6PM. During weekends Subscribers and Customers have a very similar time usage pattern, suggesting that probably during Weekends Subscribers use the service mostly for leasure purposes as probably Customers do in general.

#### Month to month usage

![](2.Analysis_files/figure-markdown_github/unnamed-chunk-4-1.png)

We clearly see a seasonality pattern, where the smallest number of trips are recorded in December and the highest in June. It is interesting that people in October are also very active. This is probably caused by the fact that in Bay Area the weather allows to ride bicycle also in this month too and there are less people on vacations than in Summer months.

### 2.2 Stations

To analyse data geographically we need to have *lat* / *long* positions of each station. We tried first to do it using the package *ggmap*, function *geo\_code*, but we get incorrect values for some stations (station name queries are ambiguous in Google Maps). Therefore we use the station data .CSV file available in the dataset package:

Bike Share program words not only in San Francisco, but also in [](http://www.bayareabikeshare.com/stations). Here is how 70 stations are spread in Bay Area (each white dot is an individual station):

![](2.Analysis_files/figure-markdown_github/unnamed-chunk-7-1.png)

### 2.3 Trips Direction

2.9% of trips end at the same Station as they started. Out of those 7.15% are immediate changes, when a rider took a bicycle and gave it back in less than 2 minutes (e.g. decided to pick another bicycle for example).

Now we analyze where Customers and Subscribers travel using shared bicycles at different time of days on Weekdays and Weekends. On the maps below we show only the stations with the highest traffic (to have the plot less cluttered with labels). The lines in red (salmon) show the trips towards North and the lines in blue (turquoise) - towards South.

#### San Francisco - Trips During Weekdays

    ## Warning: Removed 1560 rows containing missing values (geom_curve).

    ## Warning: Removed 210 rows containing missing values (geom_text_repel).

![](2.Analysis_files/figure-markdown_github/unnamed-chunk-11-1.png)

Customers do not have route priorities depending on the time of the day. In mornings many Subscribers travel to the South towards Caltrain Station and Townsend 2nd and 7th St. There are also many Subscribers travelling from Caltrain Station towards Embarcadero. In afternoons many Subscribers also travel from all the Downtown to Caltrain Station and from 2nd and Townsend to Ferry Building. In evenings Subscribers do not have such distinct routes apart from trips towards the south of Market St.

#### San Francisco - Trips During Weekends

    ## Warning: Removed 977 rows containing missing values (geom_curve).

    ## Warning: Removed 210 rows containing missing values (geom_text_repel).

![](2.Analysis_files/figure-markdown_github/unnamed-chunk-13-1.png)

During weekends the route preferences of Customers and Subscribers are similar (Market St and Embarcadero) providing an extra support for our hypothesis that Subscribers tend to use the service during weekends for leasure purposes.

#### Palo Alto - Trips During Weekdays

    ## Warning: Removed 7436 rows containing missing values (geom_curve).

    ## Warning: Removed 306 rows containing missing values (geom_text_repel).

![](2.Analysis_files/figure-markdown_github/unnamed-chunk-15-1.png)

There is a clear pattern that Subscribers go in mornings to San Antonio Shopping Center from Caltrain Station and come back in afternoons. The Same in Mountain View - Subscribers go to Castro street in mornings and come back in afternoons.

#### San Jose - Trips During Weekdays

    ## Warning: Removed 7011 rows containing missing values (geom_curve).

    ## Warning: Removed 324 rows containing missing values (geom_text_repel).

![](2.Analysis_files/figure-markdown_github/unnamed-chunk-17-1.png) Many Subscribers go to San Jose Caltrain Station in mornings and come back in evenings.

### 2.4 Intercity trips in Bay Area

Sometimes people even carry inter city trips using Bay Area Bike Share.

![](2.Analysis_files/figure-markdown_github/unnamed-chunk-19-1.png)

They are not many. Only 509 out of 354152 total trips for the period.

#### INTERESTING FACT: Three friends doing an intercity trip

We can find an interesting example how people went together from Palo Alto to San Francisco (it took them 5.13 hours) by bicycle in winter (January, 18). Thanksfuly the weather in San Francisco allows such trips. Still it was not cheap.

|        | Trip.ID | Start.Date          | End.Date            | Start.Station          | End.Station                              | DayType |
|--------|:--------|:--------------------|:--------------------|:-----------------------|:-----------------------------------------|:--------|
| 228371 | 608728  | 2015-01-18 10:28:00 | 2015-01-18 15:36:00 | University and Emerson | San Francisco Caltrain (Townsend at 4th) | Weekend |
| 228382 | 608715  | 2015-01-18 10:07:00 | 2015-01-18 15:36:00 | University and Emerson | San Francisco Caltrain (Townsend at 4th) | Weekend |
| 228383 | 608714  | 2015-01-18 10:07:00 | 2015-01-18 15:37:00 | University and Emerson | San Francisco Caltrain (Townsend at 4th) | Weekend |

3. Potential Issue Analysis
---------------------------

### 3.1 Unbalanced Stations

Blue/Purple are the stations which tend to have more bikes arriving than departing (up to 21%). Yellow are those stations that tend to have more bikes departing than arriving (up to 32%).

#### Stations in San Francisco

    ## Warning: Removed 35 rows containing missing values (geom_point).

    ## Warning: Removed 35 rows containing missing values (geom_label_repel).

![](2.Analysis_files/figure-markdown_github/unnamed-chunk-23-1.png)

#### Stations in Palo Alto, Redwood City, Mountain View

    ## Warning: Removed 51 rows containing missing values (geom_point).

    ## Warning: Removed 51 rows containing missing values (geom_label_repel).

![](2.Analysis_files/figure-markdown_github/unnamed-chunk-25-1.png)

#### Stations in San Jose

    ## Warning: Removed 54 rows containing missing values (geom_point).

    ## Warning: Removed 54 rows containing missing values (geom_label_repel).

![](2.Analysis_files/figure-markdown_github/unnamed-chunk-27-1.png)

### 3.2 Bicycle Usage

![](2.Analysis_files/figure-markdown_github/unnamed-chunk-28-1.png)

As we assumed a half of bicycles were used in average 114 times and another half 924 times. In the ideal case (all bicycles are used equaly often) each bicycle would be used 530 times.

4. Recommendations
------------------

Here below we provide recommendations how to make the distribution of bicycle usage a more uniform or normal rather than bimodal. To do it we believe that bicycles which were extensively used in areas with high traffic should be moved to stations with low traffic, while bicycles which are almost new should be moved from stations with low traffic to stations with high traffic. Moving bicycles is also a cost so we believe that the right way to do this transfer is to do it along the regular bicycle transfer caused by inbalanced stations usage.

**Based on the trips users did in the last day (based on the current dataset) we suggest to transfer bicycles based on the following recommendations.** These recommendations are balanced (the total number of bicycles to take off is equal to the total number to bring). The number of heavily- and used few times might be not balanced, but they are more priorities than an action order.

| Terminal | Station                                       | Recommendation                                                                                                                                                                                                           |
|:---------|:----------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 70       | San Francisco Caltrain (Townsend at 4th)      | Take off: 532, 29, 540, 310, 328, 327, 416, 67, 342, 556, 459, 500, 484, 158, 548, 372, 575, 597, 360, 422, 579, 531, 371, 432, 413, 709, 441, 427, 109, 274, 288, 538, 336, 619, 559, 495, 629, 635, 387, 535, 187, 637 |
| 69       | San Francisco Caltrain 2 (330 Townsend)       | Take off: 878, 334, 507, 16, 137, 278, 465, 602, 268, 516, 549, 214, 508, 526, 390, 222, 525, 614, 403, 594, 611, 353, 517                                                                                               |
| 50       | Harry Bridges Plaza (Ferry Building)          | Take off: 366, 609, 292, 419, 404, 583, 620                                                                                                                                                                              |
| 61       | 2nd at Townsend                               | Take off: 463, 66                                                                                                                                                                                                        |
| 60       | Embarcadero at Sansome                        | Take off: 409                                                                                                                                                                                                            |
| 55       | Temporary Transbay Terminal (Howard at Beale) | Bring 2 bikes used few times                                                                                                                                                                                             |
| 74       | Steuart at Market                             | Take off: 418                                                                                                                                                                                                            |
| 77       | Market at Sansome                             | Take off: 322, 592, 361, 622, 189, 375, 434, 458, 563, 567, 510                                                                                                                                                          |
| 67       | Market at 10th                                | Bring 1 bikes used few times                                                                                                                                                                                             |
| 39       | Powell Street BART                            | Take off: 464, 423                                                                                                                                                                                                       |
| 76       | Market at 4th                                 | Bring 8 bikes used few times                                                                                                                                                                                             |
| 64       | 2nd at South Park                             | Bring 4 bikes used few times                                                                                                                                                                                             |
| 57       | 5th at Howard                                 | Bring 11 bikes used few times                                                                                                                                                                                            |
| 72       | Civic Center BART (7th at Market)             | Take off: 326, 370                                                                                                                                                                                                       |
| 82       | Broadway St at Battery St                     | Bring 3 bikes used few times                                                                                                                                                                                             |
| 51       | Embarcadero at Folsom                         | Bring 7 bikes used few times                                                                                                                                                                                             |
| 56       | Beale at Market                               | Bring 13 bikes used few times                                                                                                                                                                                            |
| 63       | Howard at 2nd                                 | Bring 1 bikes used few times                                                                                                                                                                                             |
| 62       | 2nd at Folsom                                 | Bring 16 bikes used few times                                                                                                                                                                                            |
| 73       | Grant Avenue at Columbus Avenue               | Bring 10 bikes used few times                                                                                                                                                                                            |
| 75       | Mechanics Plaza (Market at Battery)           | Take off: 512, 581, 462, 325                                                                                                                                                                                             |
| 45       | Commercial at Montgomery                      | Bring 4 bikes used few times                                                                                                                                                                                             |
| 68       | Yerba Buena Center of the Arts (3rd @ Howard) | Bring 2 bikes used few times                                                                                                                                                                                             |
| 48       | Embarcadero at Vallejo                        | Take off: 491, 504                                                                                                                                                                                                       |
| 66       | South Van Ness at Market                      | Bring 5 bikes used few times                                                                                                                                                                                             |
| 49       | Spear at Folsom                               | Bring 8 bikes used few times                                                                                                                                                                                             |
| 71       | Powell at Post (Union Square)                 | Bring 7 heavily used bikes                                                                                                                                                                                               |
| 42       | Davis at Jackson                              | Take off: 569, 86                                                                                                                                                                                                        |
| 41       | Clay at Battery                               | Take off: 445                                                                                                                                                                                                            |
| 2        | San Jose Diridon Caltrain Station             | Take off: 213, 165, 663                                                                                                                                                                                                  |
| 47       | Post at Kearney                               | Take off: 523                                                                                                                                                                                                            |
| 59       | Golden Gate at Polk                           | Bring 3 heavily used bikes                                                                                                                                                                                               |
| 46       | Washington at Kearney                         | Take off: 395, 451, 290, 547                                                                                                                                                                                             |
| 4        | Santa Clara at Almaden                        | Bring 2 heavily used bikes                                                                                                                                                                                               |
| 58       | San Francisco City Hall                       | Bring 4 heavily used bikes                                                                                                                                                                                               |
| 27       | Mountain View City Hall                       | Take off: 35, 139                                                                                                                                                                                                        |
| 6        | San Pedro Square                              | Take off: 125, 163                                                                                                                                                                                                       |
| 31       | San Antonio Shopping Center                   | Bring 1 heavily used bikes                                                                                                                                                                                               |
| 29       | San Antonio Caltrain Station                  | Take off: 24                                                                                                                                                                                                             |
| 11       | MLK Library                                   | Bring 2 heavily used bikes                                                                                                                                                                                               |
| 34       | Palo Alto Caltrain Station                    | Bring 3 heavily used bikes                                                                                                                                                                                               |
| 84       | Ryland Park                                   | Bring 2 heavily used bikes                                                                                                                                                                                               |
| 9        | Japantown                                     | Bring 1 heavily used bikes                                                                                                                                                                                               |
| 30       | Evelyn Park and Ride                          | Bring 1 heavily used bikes                                                                                                                                                                                               |
| 22       | Redwood City Caltrain Station                 | Bring 1 heavily used bikes                                                                                                                                                                                               |
| 10       | San Jose City Hall                            | Bring 1 heavily used bikes                                                                                                                                                                                               |
| 37       | Cowper at University                          | Take off: 140, 230                                                                                                                                                                                                       |
| 5        | Adobe on Almaden                              | Take off: 714                                                                                                                                                                                                            |
| 8        | San Salvador at 1st                           | Take off: 130                                                                                                                                                                                                            |
| 16       | SJSU - San Salvador at 9th                    | Take off: 181                                                                                                                                                                                                            |
| 25       | Stanford in Redwood City                      | Take off: 126, 196                                                                                                                                                                                                       |
| 26       | Redwood City Medical Center                   | Bring 1 heavily used bikes                                                                                                                                                                                               |
