library(lubridate)
library(ggplot2)
library(ggmap)
library(ggrepel)
library(plyr)
library(sqldf)
library(knitr)

getTrips <- function(source_file){
	trips = read.csv(source_file)

	trips$Trip.ID <- as.factor(trips$Trip.ID)
	trips$Start.Date <- mdy_hm(as.character(trips$Start.Date))
	trips$Start.Day <- as.Date(trips$Start.Date)

	trips$Start.Hour <- hour(trips$Start.Date)
	trips$DayPart <- "1. Morning"
	trips[trips$Start.Hour > 11,]$DayPart <- "2. Afternoon"
	trips[trips$Start.Hour > 17,]$DayPart <- "3. Evening"
	trips$DayPart <- as.factor(trips$DayPart)

	trips$Start.Minute <- minute(trips$Start.Date)
	trips$Start.Month.Number <- as.numeric(month(trips$Start.Date))
	trips$Start.Month <- paste("(",trips$Start.Month.Number,")"," ", months(trips$Start.Date), sep="")
	trips$End.Date <- mdy_hm(as.character(trips$End.Date))
	trips$Start.Terminal <- as.factor(trips$Start.Terminal)
	trips$End.Terminal <- as.factor(trips$End.Terminal)
	trips$Bike <- as.factor(trips[,"Bike.."])
	trips <- trips[ , !(names(trips) %in% c("Bike.."))]
	trips$Weekday <- as.factor(wday(trips$Start.Date))
	trips$DayType <- "Weekday"
	trips[trips$Weekday %in% c(1,7),]$DayType <- "Weekend"
	trips$DayType <- as.factor(trips$DayType)
	trips$row_weight = 1

	trips
}

getStations <- function(source_file){
	stations = read.csv(source_file)

	stations$id <- as.factor(stations$station_id)
	stations$amount_out <- apply(stations, 1, function(station) nrow(trips[trips$Start.Terminal == station['id'],]))
	stations$amount_in <- apply(stations, 1, function(station) nrow(trips[trips$End.Terminal == station['id'],]))
	stations$traffic <- stations$amount_in + stations$amount_out
	stations$amount_net <- stations$amount_in - stations$amount_out
	stations$amount_net_percentage <- 100*stations$amount_net/(stations$amount_in + stations$amount_out)
	stations <- stations[order(-stations$traffic),]

	stations
}

# this function was taken from 
# http://stackoverflow.com/questions/27418461/calculate-the-modes-in-a-multimodal-distribution-in-r
find_modes <- function(x) {
  modes <- NULL
  for ( i in 2:(length(x)-1) ){
  if ( (x[i] > x[i-1]) & (x[i] > x[i+1]) ) {
    modes <- c(modes,i)
  }
  }
  if ( length(modes) == 0 ) {
    modes = 'This is a monotonic distribution'
  }
  return(modes)
}
plotBikeUsageHistogram <- function(bikes){
	md <- find_modes(density(bikes$freq)$y)

	ggp <- ggplot(bikes, aes(freq)) + geom_histogram(binwidth = 10) 
	ggp <- ggp + geom_vline(xintercept = density(bikes$freq)$x[md][1], color = "red", linetype="dashed")
	ggp <- ggp + geom_vline(xintercept = density(bikes$freq)$x[md][2], color = "red", linetype="dashed")
	
	ggp
}

getBikesPosition <- function(trips){
	bikes_usage <- sqldf("select Bike, max(`End.Date`) as dt, count(*) as used from trips group by Bike")
	bikes <- sqldf("select t.*, bu.used from bikes_usage bu inner join trips t on t.`End.Date` = bu.dt and t.Bike = bu.Bike order by bu.used desc")

	bikes
}
getTripsNet <- function(trips){
	trips_last_day <- trips[trips$Start.Day == max(trips$Start.Day),]
	trips_aggregated <- sqldf("select `Start.Terminal`,`End.Terminal`, count(*) as freq from trips_last_day where `Start.Terminal`!= `End.Terminal` group by `Start.Terminal`, `End.Terminal` ")
  	trips_net <- sqldf("
  		select Terminal, sum(amount) as amount from (
           select `End.Terminal` as Terminal, sum(freq) as amount from trips_aggregated group by `End.Terminal`
           union all 
           select `Start.Terminal` as Terminal, -1*sum(freq) as amount from trips_aggregated group by `Start.Terminal`
           ) 
        group by Terminal
        having sum(amount)!=0
                     ")
	trips_net
}
getTransferBikesRecommendations <- function(trips_net, bikes, stations){
	transfer_bikes <- sqldf("select s.id as Terminal, s.name as Station , s.traffic, tn.amount from stations s left join trips_net tn on s.id = tn.Terminal where tn.amount !=0 ")
	transfer_bikes$amount <- as.numeric(transfer_bikes$amount)
	
	transfer_bikes$Recommendation <- apply(transfer_bikes, 1, function(station){
	    station['traffic']<- as.numeric(station['traffic'])
	    station_bikes <- bikes[bikes$End.Terminal == station['Terminal'],]
	    recommendation <- ""
	    abs_amount <- abs(as.numeric(station['amount']))
	    if (as.numeric(station['traffic']) > as.numeric(median(transfer_bikes$traffic))){
	      if (as.numeric(station['amount'])>0){
	        recommendation <- paste("Take off: ",paste(head(station_bikes,abs_amount)$Bike, collapse=", "),sep="")
	      }else{
	        recommendation <- paste("Bring ",abs(as.numeric(station['amount']))," bikes used few times",sep="")
	      }
	    }else{
	      if (as.numeric(station['amount'])>0){
	        recommendation <- paste("Take off: ",paste(tail(station_bikes,abs_amount)$Bike, collapse=", "),sep="")
	      }else{
	         recommendation <- paste("Bring ",abs(as.numeric(station['amount']))," heavily used bikes",sep="")
	    	}
	    }
	    recommendation
	})
	transfer_bikes$Recommendation <- as.factor(transfer_bikes$Recommendation)
	
	transfer_bikes
}

getAggregatedTrips <- function(trips){
	# Aggregate trips by Terminals, Subscriber and Daytime
	trips_daily = count(trips[trips$End.Terminal != trips$Start.Terminal,], .(Start.Terminal, End.Terminal, Subscriber.Type, DayType, DayPart))

	# Augment the aggregated trips with geo positions of stations
	trips_daily$Start.Station.long <- apply(trips_daily, 1, function(trip) stations[stations$id == trip['Start.Terminal'],'long'])
	trips_daily$Start.Station.lat <- apply(trips_daily, 1, function(trip) stations[stations$id == trip['Start.Terminal'],'lat'])
	trips_daily$End.Station.long <- apply(trips_daily, 1, function(trip) stations[stations$id == trip['End.Terminal'],'long'])
	trips_daily$End.Station.lat <- apply(trips_daily, 1, function(trip) stations[stations$id == trip['End.Terminal'],'lat'])
	trips_daily$Start.City <- apply(trips_daily, 1, function(trip) stations[stations$id == trip['Start.Terminal'],'landmark'])
	trips_daily$End.City <- apply(trips_daily, 1, function(trip) stations[stations$id == trip['End.Terminal'],'landmark'])

	# Augment the aggregated trips with the direction of trips
	trips_daily$Direction <- "North"
	trips_daily[trips_daily$End.Station.lat < trips_daily$Start.Station.lat,]$Direction <- "South"
	trips_daily$Direction <- as.factor(trips_daily$Direction)

	trips_daily
} 
getFlowPlot <- function(area_map, trips_daily, stations, show_labels = TRUE){
	FlowPlot <- ggmap(area_map, extent = "device", ylab = "Latitude", xlab = "Longitude",darken = 0.75) + 
	geom_curve(data = trips_daily, aes(x=Start.Station.long, xend=End.Station.long, y=Start.Station.lat, yend=End.Station.lat, color=   Direction, alpha = freq, size = freq), curvature = 0.05, inherit.aes = TRUE) +
	facet_grid(DayPart ~ Subscriber.Type) +
	scale_alpha(limits=c(0, max(trips_daily$freq)), guide=FALSE) +
	scale_size(limits=c(0, max(trips_daily$freq)), guide=FALSE) + theme(legend.position="bottom")+coord_cartesian()
	
	if (show_labels == TRUE){
		FlowPlot <- FlowPlot + geom_text_repel(data=stations, aes(long, lat, label = name, alpha = traffic), color = 'white', size =2, segment.color = 'white')
	}

	FlowPlot
}
getStationsBalancePlot <- function(area_map, stations){
	ggmap(area_map, extent = "device", ylab = "Latitude", xlab = "Longitude",darken = 0.75) + 
	geom_point(data = stations, aes(x=long, y=lat,  size = traffic), shape = 1, color = "white", )+
	scale_fill_gradientn(colors=c("#f9ed32", "#ee2a7b","#002aff"),limits=c(-35, 35), name="Traffic in over out, %")+
	scale_shape_discrete(solid=F) +
	geom_label_repel(
	    data=stations,
	   	aes(long, lat, fill = stations$amount_net_percentage, label = paste(name, round(stations$amount_net_percentage,0),"%", sep=" ")),
	    fontface = 'bold', color = 'white',
	    box.padding = unit(0.25, "lines"),
	    point.padding = unit(0.5, "lines")
	  ) + theme(legend.position="bottom")
}