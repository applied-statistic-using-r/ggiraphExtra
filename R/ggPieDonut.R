#'Draw a Pie and Donut plot
#'@param data A data.frame
#'@param mapping Set of aesthetic mappings created by aes or aes_.
#'@param addPieLabel A logical value. If TRUE, labels are added to the Pies
#'@param addDonutLabel A logical value. If TRUE, labels are added to the Donuts
#'@param showRatioDonut A logical value. If TRUE, Ratios are added to the DonutLabels
#'@param showRatioPie A logical value. If TRUE, Ratios are added to the PieLabels
#'@param showRatioPieAbove10 A logical value. If TRUE, labels are added to the Pies with ratio above 10.
#'@param title Plot title
#'@param labelposition A number indicating the label position
#'@param polar A logical value. If TRUE, coord_polar() function will be added
#'@param use.label Logical. Whether or not use column label in case of labelled data
#'@param use.labels Logical. Whether or not use value labels in case of labelled data
#'@param interactive A logical value. If TRUE, an interactive plot will be returned
#'@importFrom grDevices rainbow
#'@importFrom ggplot2 geom_segment
#'@export
#'@return An interactive Pie and Donut plot
#'@examples
#'require(ggplot2)
#'require(ggiraph)
#'require(plyr)
#'require(moonBook)
#'ggPieDonut(acs,aes(pies=Dx,donuts=smoking))
#'ggPieDonut(acs,aes(pies=smoking))
#'ggPieDonut(browsers,aes(pies=browser,donuts=version,count=share))
#'ggPieDonut(browsers,aes(x=c(browser,version),y=share),interactive=TRUE)
ggPieDonut=function(data,mapping,
                    #pies="Dx",donuts="smoking",count=NULL,
                    addPieLabel=TRUE,addDonutLabel=TRUE,
                    showRatioDonut=TRUE,showRatioPie=TRUE,
                    showRatioPieAbove10=TRUE,title="",
                    labelposition=1, polar=TRUE,
                    use.label=TRUE,use.labels=TRUE,
                    interactive=FALSE){

         #data=browsers;mapping=aes(pies=browser,donuts=version,count=share)
        # data=acs;mapping=aes(donuts=Dx)
        # addPieLabel=TRUE;addDonutLabel=TRUE
        # showRatioDonut=TRUE;showRatioPie=TRUE
        # showRatioPieAbove10=TRUE;title=""
        # labelposition=1; polar=TRUE;interactive=FALSE
        (cols=colnames(data))
        if(use.labels) data=addLabelDf(data,mapping)

        count<-NULL
        if("y" %in% names(mapping)){
                count<-paste(mapping[["y"]])
        } else {
                if("count" %in% names(mapping)) count<-paste(mapping[["count"]])
        }
        count
        (pies=paste0(mapping[["pies"]]))
        if(length(pies)==0) pies<-NULL
        (donuts=paste0(mapping[["donuts"]]))
        if(length(donuts)==0) donuts<-NULL
        if((length(pies)+length(donuts))!=2){
                (xvar=paste0(mapping[["x"]]))
                xvar=paste0(mapping[["x"]])
                #if(length(xvar)<2) warning("Two variables are required")
                if(length(xvar)>1) {
                        xvar<-xvar[-1]
                        pies=xvar[1]
                        donuts=xvar[2]
                }
        }
        if((length(pies)+length(donuts))==1) {
                if(is.null(pies)) {
                        p<-ggDonut(data,mapping,addDonutLabel=addDonutLabel,
                                             showRatio=showRatioDonut,title=title,
                                             labelposition=labelposition, polar=polar,interactive=interactive)
                } else {
                        p<-ggPie(data,mapping,title=title,
                                               addPieLabel=addPieLabel,showRatioPie=showRatioPie,
                                               showRatioPieAbove10=showRatioPieAbove10,
                                                 labelposition=labelposition, polar=polar,interactive=interactive)
                }
        } else {
                if(is.null(count)){
                        dat1=ddply(data,c(pies,donuts),nrow)
                        colnames(dat1)[3]="n"

                        dat1$ymax=cumsum(dat1$n)
                        dat1$ymin=cumsum(dat1$n)-dat1$n
                        dat1$ypos=dat1$ymin+dat1$n/2
                        dat1$ratio=dat1$n*100/sum(dat1$n)
                        dat1$cumratio=dat1$ypos*100/sum(dat1$n)
                        dat1$hjust=ifelse((dat1$cumratio>25 & dat1$cumratio<75),0,1)
                        dat1$label=paste0(dat1[[pies]],'<br>',dat1[[donuts]],"<br>",dat1$n,"(",round(dat1$ratio,1),"%)")

                        #print(dat1)

                        data2=ddply(data,pies,nrow)
                        colnames(data2)[2]="sum"
                        #data2=data2[order(data2$sum,decreasing=TRUE),]
                        data2$cumsum=cumsum(data2$sum)
                        data2$pos=data2$cumsum-data2$sum/2
                        data2$ymin=data2$cumsum-data2$sum
                        data2$ratio=data2$sum*100/sum(data2$sum)
                        data2$label=ifelse(data2$ratio>10,
                                           paste0(data2[[pies]],"<br>",data2$sum,"(",round(data2$ratio,1),"%)"),
                                           paste0(data2[[pies]]))
                        data2$tooltip=paste0(data2[[pies]],"<br>",data2$sum,"(",round(data2$ratio,1),"%)")
                        #print(data2)


                } else{
                        dat1=data
                        colnames(dat1)[colnames(dat1)==count]="n"
                        dat1$ymax=cumsum(dat1$n)
                        dat1$ymin=cumsum(dat1$n)-dat1$n
                        dat1$ypos=dat1$ymin+dat1$n/2
                        dat1$ratio=dat1$n*100/sum(dat1$n)
                        dat1$cumratio=dat1$ypos*100/sum(dat1$n)
                        dat1$hjust=ifelse((dat1$cumratio>25 & dat1$cumratio<75),0,1)
                        dat1$label=paste0(dat1[[pies]],"<br>",dat1[[donuts]],"<br>",dat1$n,"(",round(dat1$ratio,1),"%)")

                        dat1
                        #print(dat1)
                        pies

                        data2=eval(parse(text="ddply(dat1,pies,summarize,sum(n))"))
                        data2
                        colnames(data2)[2]="sum"
                        data2=data2[order(data2$sum,decreasing=TRUE),]
                        data2$cumsum=cumsum(data2$sum)
                        data2$pos=data2$cumsum-data2$sum/2
                        data2$ymin=data2$cumsum-data2$sum
                        data2$ratio=data2$sum*100/sum(data2$sum)
                        data2$label=ifelse(data2$ratio>10,
                                           paste0(data2[[pies]],"<br>",data2$sum,"(",round(data2$ratio,1),"%)"),
                                           paste0(data2[[pies]]))
                        data2$tooltip=paste0(data2[[pies]],"<br>",data2$sum,"(",round(data2$ratio,1),"%)")
                        #print(data2)


                }
                mainCol=rainbow(nrow(data2))
                subCol=subcolors(dat1,pies,mainCol)
                #subCol
                p<-ggplot(dat1) +
                        geom_rect_interactive(aes_string( ymax="ymax", ymin="ymin", xmax="4", xmin="3",
                                                          tooltip="label",data_id=donuts),fill=subCol,colour="white")

                p<-p+     geom_rect_interactive(aes_string(ymax="cumsum", ymin="ymin", xmax="3", xmin="0",
                                                           tooltip="tooltip",data_id=pies),data=data2,
                                                fill=mainCol,colour="white",alpha=0.7)
                p<-p+    theme_clean()

                if(addDonutLabel) {
                        label2=dat1[[donuts]]
                        if(showRatioDonut)
                                label2=paste0(label2,"\n(",round(dat1$ratio,1),"%)")
                        if(polar){
                                if(labelposition==1) {
                                        p<- p+ geom_text(aes_string(label="label2",x="4.3",y="ypos",hjust="hjust"),size=3)+
                                                geom_segment(aes_string(x="4",xend="4.2",y="ypos",yend="ypos"))
                                }  else{
                                        p<- p+ geom_text(aes_string(label="label2",x="3.5",y="ypos"),size=3)
                                }
                        } else{
                                p<-p+ geom_text(aes_string(label="label2",x="3.5",y="ypos"),size=3)

                        }

                }
                if(addPieLabel) {
                        Pielabel=data2[[pies]]
                        if(showRatioPie) {
                                if(showRatioPieAbove10) {
                                        Pielabel=ifelse(data2$ratio>10,
                                                        paste0(data2[[pies]],"\n(",round(data2$ratio,1),"%)"),
                                                        paste0(data2[[pies]]))
                                }
                                else Pielabel=paste0(Pielabel,"\n(",round(data2$ratio,1),"%)")
                        }
                        p<-p+geom_text(data=data2,aes_string(label="Pielabel",x="1.5",y="pos"),size=4)
                }
                if(polar) p<-p+coord_polar(theta="y",start=3*pi/2)
                if(title!="") p<-p+ggtitle(title)
                if(use.label){
                        labels=c()
                        for(i in 1:length(cols)) {
                                temp=get_label(data[[cols[i]]])
                                labels=c(labels,ifelse(is.null(temp),cols[i],temp))
                        }
                        labels
                        # angles=(90-(0:(length(labels)-1))*(360/length(labels)))-5
                        # angles
                        # angles[which(angles < -90)]=angles[which(angles < -90)]+180
                        p<-p+scale_x_discrete(labels=labels)
                        #theme(axis.text.x=element_text(angle=angles))

                }

                if(interactive) p<-ggiraph(code=print(p),zoom_max=10)
                p

        }
        p

}

#'Draw a Donut plot
#'@param data A data.frame
#'@param mapping Set of aesthetic mappings created by aes or aes_.
#'@param addDonutLabel A logical value. If TRUE, labels are added to the Donuts
#'@param showRatio A logical value. If TRUE, Ratios are added to the DonutLabels
#'@param polar A logical value. If TRUE, coord_polar() function will be added
#'@param labelposition A number indicating the label position
#'@param title Plot title
#'@param use.label Logical. Whether or not use column label in case of labelled data
#'@param use.labels Logical. Whether or not use value labels in case of labelled data
#'@param interactive A logical value. If TRUE, an interactive plot will be returned
#'@importFrom ggplot2 xlim geom_segment
#'@importFrom grDevices rainbow
#'@export
#'@return An interactive Pie and Donut plot
#'@examples
#'require(ggplot2)
#'require(ggiraph)
#'require(plyr)
#'ggDonut(browsers,aes(donuts=version,count=share))
ggDonut=function(data,mapping,

                 addDonutLabel=TRUE,showRatio=TRUE,
                 polar=TRUE,labelposition=1,title="",
                 use.label=TRUE,use.labels=TRUE,
                 interactive=FALSE){

        # (cols=colnames(data))
        if(use.labels) data=addLabelDf(data,mapping)

        donuts<-count<-NULL
        if("y" %in% names(mapping)) count<-paste(mapping[["y"]])
        else if("count" %in% names(mapping)) count<-paste(mapping[["count"]])
        if("donuts" %in% names(mapping)) donuts<-paste(mapping[["donuts"]])
        else if("x" %in% names(mapping)) donuts<-paste(mapping[["x"]])


        if(is.null(count)){
                dat1=ddply(data,donuts,nrow)
                colnames(dat1)[2]="n"
        } else{
                dat1=data
                colnames(dat1)[colnames(dat1)==count]="n"
        }
        dat1$ymax=cumsum(dat1$n)
        dat1$ymin=cumsum(dat1$n)-dat1$n
        dat1$ypos=dat1$ymin+dat1$n/2
        dat1$ratio=dat1$n*100/sum(dat1$n)
        dat1$cumratio=dat1$ypos*100/sum(dat1$n)
        dat1$hjust=ifelse((dat1$cumratio>25 & dat1$cumratio<75),0,1)
        dat1$label=paste0(dat1[[donuts]],"<br>",dat1$n,"(",round(dat1$ratio,1),"%)")

        mainCol=rainbow(nrow(dat1))
        p<-ggplot(dat1) +
                geom_rect_interactive(aes_string( ymax="ymax", ymin="ymin", xmax="4", xmin="3",
                                                  tooltip="label",data_id=donuts),fill=mainCol,colour="white",alpha=0.7)+
                coord_polar(theta="y",start=3*pi/2)+
                xlim(0,4+labelposition)+
                theme_clean()

        donutlabel=dat1[[donuts]]
        if(showRatio)
                donutlabel=paste0(donutlabel,"\n(",round(dat1$ratio,1),"%)")

        if(labelposition==1) {
                p<- p+ geom_text(aes_string(label="donutlabel",x="4.3",y="ypos",hjust="hjust"),size=3)+
                        geom_segment(aes_string(x="4",xend="4.2",y="ypos",yend="ypos"))
        }  else{
                p<- p+ geom_text(aes_string(label="donutlabel",x="3.5",y="ypos"),size=3)
        }
        if(title!="") p<-p+ggtitle(title)
        # if(use.label){
        #         labels=c()
        #         for(i in 1:length(cols)) {
        #                 temp=get_label(data[[cols[i]]])
        #                 labels=c(labels,ifelse(is.null(temp),cols[i],temp))
        #         }
        #         labels
        #         # angles=(90-(0:(length(labels)-1))*(360/length(labels)))-5
        #         # angles
        #         # angles[which(angles < -90)]=angles[which(angles < -90)]+180
        #         #p<-p+scale_x_discrete(labels=labels)
        #         #theme(axis.text.x=element_text(angle=angles))
        #
        # }

        if(interactive) p<-ggiraph(code=print(p),zoom_max = 10)
        p

}

#'Make a subcolors according to the mainCol
#'
#'@param .dta A data.frame
#'@param main A character string of column name used as a main variable
#'@param mainCol A main color
#'@importFrom grDevices col2rgb rgb
#'@export
subcolors <- function(.dta,main,mainCol){
        tmp_dta = cbind(.dta,1,'col')
        tmp1 = unique(.dta[[main]])
        for (i in 1:length(tmp1)){
                tmp_dta$"col"[.dta[[main]] == tmp1[i]] = mainCol[i]
        }
        u <- unlist(by(tmp_dta$"1",tmp_dta[[main]],cumsum))
        n <- dim(.dta)[1]
        subcol=rep(rgb(0,0,0),n);
        for(i in 1:n){
                t1 = col2rgb(tmp_dta$col[i])/256
                subcol[i]=rgb(t1[1],t1[2],t1[3],1/(1+u[i]))
        }
        return(subcol);
}


#'Draw a pie plot
#'@param data A data.frame
#'@param mapping Set of aesthetic mappings created by aes or aes_.
#'@param addPieLabel A logical value. If TRUE, labels are added to the Pies
#'@param showRatioPie A logical value. If TRUE, Ratios are added to the PieLabels
#'@param showRatioPieAbove10 A logical value. If TRUE, labels are added to the Pies with ratio above 10.
#'@param title Plot title
#'@param labelposition A number indicating the label position
#'@param polar A logical value. If TRUE, coord_polar() function will be added
#'@param use.label Logical. Whether or not use column label in case of labelled data
#'@param use.labels Logical. Whether or not use value labels in case of labelled data
#'@param interactive A logical value. If TRUE, an interactive plot will be returned
#'@export
#'@return An interactive pie plot
#'@examples
#'require(ggplot2)
#'require(ggiraph)
#'require(plyr)
#'require(moonBook)
#'ggPie(data=browsers,aes(pies=browser,count=share))
#'ggPie(data=acs,aes(pies=Dx))
ggPie=function(data,mapping,
                    #pies="Dx",count=NULL,
                    addPieLabel=TRUE,showRatioPie=TRUE,
                    showRatioPieAbove10=TRUE,title="",
                    labelposition=1, polar=TRUE,
                    use.label=TRUE,use.labels=TRUE,
                    interactive=FALSE){

         # data=browsers;mapping=aes(pies=browser,count=share)
         # addPieLabel=TRUE;addDonutLabel=TRUE
         # showRatioDonut=TRUE;showRatioPie=TRUE
         # showRatioPieAbove10=TRUE;title=""
         # labelposition=1; polar=TRUE;interactive=FALSE

        (cols=colnames(data))
        if(use.labels) data=addLabelDf(data,mapping)

        count<-NULL
        if("y" %in% names(mapping)){
                count<-paste(mapping[["y"]])
        } else {
                if("count" %in% names(mapping)) count<-paste(mapping[["count"]])
        }

        (pies=paste0(mapping[["pies"]]))
        if(length(pies)!=1){
                (xvar=paste0(mapping[["x"]]))
                pies=xvar[1]

        }

        if(is.null(count)){

                data2=ddply(data,pies,nrow)
                colnames(data2)[2]="sum"
                #data2=data2[order(data2$sum,decreasing=TRUE),]
                data2$cumsum=cumsum(data2$sum)
                data2$pos=data2$cumsum-data2$sum/2
                data2$ymin=data2$cumsum-data2$sum
                data2$ratio=data2$sum*100/sum(data2$sum)
                data2$label=ifelse(data2$ratio>10,
                                   paste0(data2[[pies]],"<br>",data2$sum,"(",round(data2$ratio,1),"%)"),
                                   paste0(data2[[pies]]))
                data2$tooltip=paste0(data2[[pies]],"<br>",data2$sum,"(",round(data2$ratio,1),"%)")
                #print(data2)

        } else{

                #data2=eval(parse(text="ddply(dat1,pies,summarize,sum(n))"))
                data2=data[c(pies,count)]
                colnames(data2)[2]="sum"
                data2=ddply(data2,pies,summarize,sum=sum(sum))
                data2
                colnames(data2)[2]="sum"
                data2=data2[order(data2$sum,decreasing=TRUE),]
                data2
                data2$cumsum=cumsum(data2$sum)
                data2$pos=data2$cumsum-data2$sum/2
                data2$ymin=data2$cumsum-data2$sum
                data2$ratio=data2$sum*100/sum(data2$sum)
                data2$label=ifelse(data2$ratio>10,
                                   paste0(data2[[pies]],"<br>",data2$sum,"(",round(data2$ratio,1),"%)"),
                                   paste0(data2[[pies]]))
                data2$tooltip=paste0(data2[[pies]],"<br>",data2$sum,"(",round(data2$ratio,1),"%)")
                #print(data2)


        }
        mainCol=rainbow(nrow(data2))
        #subCol=subcolors(dat1,pies,mainCol)
        #subCol
        p<-ggplot(data2) +
                geom_rect_interactive(aes_string(ymax="cumsum", ymin="ymin", xmax="3", xmin="0",
                                                           tooltip="tooltip",data_id=pies),
                                                fill=mainCol,colour="white",alpha=0.7)
        p<-p+    theme_clean()

        if(addPieLabel) {
                Pielabel=data2[[pies]]
                if(showRatioPie) {
                        if(showRatioPieAbove10) {
                                Pielabel=ifelse(data2$ratio>10,
                                                paste0(data2[[pies]],"\n(",round(data2$ratio,1),"%)"),
                                                paste0(data2[[pies]]))
                        }
                        else Pielabel=paste0(Pielabel,"\n(",round(data2$ratio,1),"%)")
                }
                p<-p+geom_text(data=data2,aes_string(label="Pielabel",x="1.5",y="pos"),size=4)
        }
        if(polar) p<-p+coord_polar(theta="y",start=3*pi/2)
        if(title!="") p<-p+ggtitle(title)
        if(use.label){
                labels=c()
                for(i in 1:length(cols)) {
                        temp=get_label(data[[cols[i]]])
                        labels=c(labels,ifelse(is.null(temp),cols[i],temp))
                }
                labels
                # angles=(90-(0:(length(labels)-1))*(360/length(labels)))-5
                # angles
                # angles[which(angles < -90)]=angles[which(angles < -90)]+180
                p<-p+scale_x_discrete(labels=labels)
                #theme(axis.text.x=element_text(angle=angles))

        }

        if(interactive) p<-ggiraph(code=print(p),zoom_max=10)
        p

}
