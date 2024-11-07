
setwd("/Users/sichenghao/Documents/GitHub/sodium_gcs_mortality/analysis/")

png("Figure.png", width = 10, height = 4, units = 'in', res = 1000)
ggplot()+
  geom_area(data=mediation_results_propmediated,aes(x=cat,y=Estimate*100,fill=results))+
  xlab('Baseline Sodium Category')+
  ylab('%')+
  # scale_color_manual(labels = c("Proportion Mediated"), values = c("#f1c40f"))+
  scale_fill_manual(labels = c("Proportion Mediated"), values = c("#f1c40f"))+
  labs(colour='Mortality Risk', fill='Proportion Mediated') +
  theme(legend.position="bottom")+
  theme_minimal()+
  scale_x_continuous(breaks = c(1,2,3,4,5,6,7,8),labels = c("<120","120-125","125-130","130-135","135-140(reference)","140-145","145-150",">150")) +
  
  geom_point(data = total_effect,aes(x=cat,y=(or-1)*100,colour="red"))+
  geom_line(data = total_effect,aes(x=cat,y=(or-1)*100,colour="red"))+
  geom_errorbar(data=total_effect
                ,aes(x=cat,ymin=(or.lb-1)*100,ymax=(or.ub-1)*100)
                ,alpha=0.3
                ,inherit.aes=FALSE
                ,width=0.2)+
  scale_y_continuous(
    position ="right",
    
    # Features of the first axis
    name = "Proportion of mortality mediated by GCS score (%)",
    
    # Add a second axis and specify its features
    sec.axis = sec_axis(~(./100)+1, name="Odds ratio (95%CI) of hospital mortality")
  ) 
dev.off()
par(mfrow = c(1,1))


#Sensitivity Plot
png("Figure2-11.png", width = 5, height = 4, units = 'in', res = 1000)
plot(sens.out1, sens.par = "rho", main = "Sensitivity Analysis", ylim = c(-0.05, 0.05))
dev.off()
par(mfrow = c(1,1))

