
library(data.table)
my_data <- read.table(file = "clipboard", sep = "\t", header = TRUE)
str(my_data)
View(my_data)
#Exploratory Data Analysis
library(ggplot2)

#Exploratory - See the amount of variation explained by the variables Early Followers, Pioneers and Late Entrants
summary(lm(ms~pion+ef, data = my_data))

summary(lm(ms~price+qual+mktexp+plb, data = my_data))

#Correlation matrix for the data
res <- cor(my_data[,c(1,2,3,4,13,15,19,20,22,23)])
round(res, 2)
library(Hmisc) # pvalue significance levels of correlation matrix
res2 <- rcorr(as.matrix(my_data[,c(1,2,3,4,5,13,15,19,20,22,23)]))
res2
res2$r # Extracting the correlation coefficients
res2$P # Extract P values

library(corrplot)
corrplot(res, type = "upper", order = "hclust", 
         tl.col = "black", tl.srt = 45)
# Insignificant correlation are crossed
corrplot(res2$r, type="upper", order="hclust", 
         p.mat = res2$P, sig.level = 0.01, insig = "blank")
# Insignificant correlations are leaved blank
corrplot(res2$r, type="upper", order="hclust", 
         p.mat = res2$P, sig.level = 0.01, insig = "blank")
library(PerformanceAnalytics)
chart.Correlation(my_data[,c(1,2,3,4,5,6,13,15,19,20,22,23)], histogram=TRUE, pch=19)
  #In the above plot:
  #The distribution of each variable is shown on the diagonal.
  #On the bottom of the diagonal : the bivariate scatter plots with a fitted line are displayed
  #On the top of the diagonal : the value of the correlation plus the significance level as stars
  #ach significance level is associated to a symbol : p-values(0, 0.001, 0.01, 0.05, 0.1, 1) <=> symbols("***", "**", "*", ".", " ")

# Get some colors
col<- colorRampPalette(c("blue", "white", "red"))(20)
heatmap(x = res, col = col, symm = TRUE)
#x : the correlation matrix to be plotted
#col : color palettes
#symm : logical indicating if x should be treated symmetrically; can only be true when x is a square matrix.

DF <- my_data
DF[] <- lapply(DF,as.integer)
library(sjPlot)
sjp.corr(DF)
sjt.corr(DF)
?sjp.corr


#Modelling
#First modelling 
olsmodel <- lm(ms~qual+plb+price+dc+pion+ef+emprody+phpf+plpf+psc+papc+mktexp, data = my_data)
summary(olsmodel)

first.stage.1 <- lm(qual~price+dc+pion+ef+tyrp+mktexp+pnp, data = my_data)
summary(first.stage.1)

my_data$inst.quality <- first.stage.1$fitted.values

first.stage.2 <- lm(plb~dc+pion+tyrp+ef+pnp+custtyp+ncust+custsize, data = my_data)
summary(first.stage.2)

my_data$inst.plb <- first.stage.2$fitted.values

first.stage.3 <- lm(price~ms+qual+dc+pion+ef+tyrp+mktexp+pnp+cap+union, data = my_data)
summary(first.stage.3)

my_data$inst.price <- first.stage.3$fitted.values

first.stage.4 <- lm(dc~ms+qual+pion+ef+tyrp+cap+price+plb, data = my_data)
summary(first.stage.4)

my_data$inst.dc <- first.stage.4$fitted.values

install.packages("AER")
library(AER)
tslsmodel<-ivreg(ms~inst.dc+inst.price+inst.quality+inst.plb+pion+ef+phpf+plpf+psc+papc+ncomp+mktexp|inst.dc+inst.price+inst.quality+inst.plb, data = my_data)
summary(tslsmodel)

install.packages("estimatr")
library(estimatr)
rob_model<-iv_robust(ms~inst.dc+inst.price+inst.quality+inst.plb+pion+ef+phpf+plpf+psc+papc+ncomp+mktexp|inst.dc+inst.price+inst.quality+inst.plb, data = my_data)
summary(rob_model)

model_fin<-lm(ms~inst.dc+inst.price+inst.quality+inst.plb+pion+ef+phpf+plpf+psc+papc+ncomp+mktexp, data = my_data)
summary(model_fin)
