# Data analysis - 01 - linear regression, prediction, working with outliers

##########
# EX02
#########
# Make a correlation diagram and find a regression line for the house price
# and number of rooms data. With significance level = 5%, does the number of rooms
# have an impact on the price? What will be the price of the apartment
# two-room apartment according to the estimated model?
# Are the assumptions of the model fulfilled?

# Clear enviroment
rm(list=ls())

# Vectors with data
price <- c(300, 250, 400, 550, 317, 389, 425, 289, 389, 559) 
rooms <- c(3, 3, 4, 5, 4, 3, 6, 3, 4, 5)

# Combine vectors to data frame
dataset02 <- data.frame(price,rooms) 


# Create scatter plot:
plot(data = dataset02,
     # price should be on y axis
     price ~ rooms, 
     pch = 20, cex = 1.5,
     xlab = 'Number of rooms', ylab = 'Price (k PLN)')

# Linear model (Model 2A):
model_2a = lm(price ~ rooms, data = dataset02)
abline(model_2a, col = 2, lwd = 2)


# With ggplot:
library(ggplot2)
ggplot(data = dataset02, aes(x = rooms, y = price)) +
  geom_point(data = dataset02, aes(x = rooms, y = price)) +
  geom_smooth(method = 'lm', colour = 2) +
  labs(x = 'Number of rooms', y = "Price (k PLN)")


# Summary
summary(model_2a)
# Adjusted R-squared: 0.4846 (variance in price of the apartment depends on 48%
# on the number of rooms). Not good enough, we aim for at least 60%.
# p-value: 0.01521 (OK = less than 0.05, significance level)

# Significance of Pearson's coeff
cor.test(~ price + rooms, data = dataset02) 
# cor = 0.7361 (strong positive corellation)


# Predict price of 2-room apt:
tworooms <- data.frame(rooms=c(2))

# All data (model.2a) >> 240.6 k PLN
# Equation: 73.1 * 2 + 94.4
# Predict function:
predict(model_2a,tworooms)

##############
# ANSWER:
##############

# With significance level = 0.05 assumptions of model are met. There is strong
# positive correlation between number of rooms and the price (price depends on
# 73% on number of the rooms). Possibly, with removing outlier observation,
# general parameters of the model (adjusted R-squared, p-value, normality etc.)
# can improve.
#
# Price of 2 rooms apartment: 240.6 k PLN.




########################
# Additional analysis:
#######################

# Residuals histogram - histogram suggests that the residuals are not
# normally distributed (right skewed) >> there are some outliers
resid(model_2a)
hist(resid(model_2a), col = 2)

# Shapiro test p-value = 0.5969
# p-value slightly higher than 0.05, so we can keep null hypothesis (the test 
# rejects the hypothesis of normality when the p-value is <= 0.05), but more
# observations would be better. 
shapiro.test((resid(model_2a))) 

# Constant variance >> points are not symmetrically distributed, there are potential outliers
plot(model_2a, 1, pch = 20) 

# Normality >> OK in our case - symmetrical
plot(model_2a, 2, pch = 20) 

# Influential points >> obs. #7 highly influences the regression line
plot(model_2a, 5, pch = 20) 

# Based on histogram, constant variance and influential points there is outlier (#7)

# Divide data set into 2: observations w/o outlier (w/o #7) + outlier (#7)
dataset02A <- dataset02[-7,]
dataset02B <- dataset02[7,]

dataset02A <- dataset02A[,c(2,1)] # change column order, easier to plot later
dataset02B <- dataset02B[,c(2,1)]

# Create empty plot, based on initial data (>> extended axis to reflect outlier))
plot(data = dataset02,
     price  ~ rooms,
     type = 'n',
     xlab = 'Number of rooms',
     ylab = 'Price (k PLN)') +
  
  legend('topleft',
         legend = c('Model 2B (w/o outlier)','Model 2A (all observations)'),
         lwd = 3,
         lty = c('solid','dotted'),
         col = c(2,'darkgrey'))

# Add data points:
points(dataset02A, pch = 20, cex = 1.5) +
  points(dataset02B, pch = 20, col = 2, cex = 1.5)

# Linear model for data w/o outlier:
model_2b = lm(price ~ rooms, data = dataset02A)

# Regression lines:
abline(model_2a, col = 'darkgrey', lwd = 2, lty ='dotted') +
  abline(model_2b, col = 2, lwd = 2)



# With ggplot
ggplot(data = dataset02, aes(x = rooms, y = price)) +
  
  # Data points:
  geom_point(data = dataset02A, size = 2) +
  geom_point(data = dataset02B, colour = 'red', size = 2.5) +
  
  # Model w/o observation #7:
  geom_smooth(data = dataset02A, method = 'lm', se = FALSE, fullrange = TRUE,
              aes(x = rooms, y = price,
                  colour = 'Model w/o outlier',
                  linetype = 'Model w/o outlier')) +
  
  # Model with all observations:
  geom_smooth(data = dataset02, method = 'lm', se = FALSE,
              aes(x = rooms, y = price,
                  colour = 'Model with all observations',
                  linetype = 'Model with all observations')) +
  
  scale_color_manual(name = 'Model', values = c('red','darkgrey')) +
  scale_linetype_manual(name = 'Model', values = c(1,3)) +
  
  labs(x = 'Number of rooms', y = "Price (k PLN)")


# Summary
summary(model_2b)
# Adjusted R-squared: 0.7425 (vs 0.48 in Model 2A). Residuals
# are more symmetrical (from -91.4 to 96.9) >> improvement
# p-value: 0.001741 (vs 0.01521 in Model 2A) >> significant improvement

# Significance of Pearson's coeff
cor.test(~ price + rooms, data = dataset02A) 
# p = 0.001741 (vs 0.015 in Model 2A)
# cor = 0.8802 (vs 0.7361 in Model 2A)

# Residuals histogram - residuals are normally distributed
hist(resid(model_2b), col = 2)

# Shapiro test p-value = 0.9398
# p-value close to 1 >> in model 2B price strongly depends on the number of rooms
shapiro.test((resid(model_2b))) 

# Constant variance 
# Points are rather symmetrically distributed, potential outliers: #5, #6
plot(model_2b, 1, pch = 20) 

# Normality
# Rather OK in our case - rather symmetrical, potential outliers: #5, #6
plot(model_2b, 2, pch = 20) 

# Influential points: observation #6 another potential outlier
plot(model_2b, 5, pch = 20) 



# Predict price of 2-room apt:
tworooms <- data.frame(rooms=c(2))

# All data (model.2a) >> 240.6 k PLN
# Equation: 73.1 * 2 + 94.4
# Predict function:
predict(model_2a,tworooms)

# w/o outlier #7 >> 175.8 k PLN
# Equation: 116.30 * 2 - 56.80
# Predict function:
predict(model_2b,tworooms)



# Predict price of #7 observation (actual data: 6 rooms / 425k PLN):
sixrooms <- data.frame(rooms=c(6))

# Model 1A >> price predicted: 533 k PLN
predict(model_2a,sixrooms)

# Model 1B >> price predicted: 641 k PLN
predict(model_2b,sixrooms)
