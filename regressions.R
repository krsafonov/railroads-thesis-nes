setwd('/Users/kr-safonov/Documents/railways/railroad_network/src')

data <- read.csv('provinces_reg.csv')

library("ivreg")
library("sandwich")

ols1 <- lm(real_graph ~ count_graph, data = data)
clustered_se <- vcovHC(ols1, type = "HC1", cluster = "General")
summary(ols1, vcov = clustered_se)

ols2 <- lm(real_graph ~ count_graph + C(General), data = data)
clustered_se <- vcovHC(ols2, type = "HC1", cluster = "General")
summary(ols2, vcov = clustered_se)

ols3 <- lm(real_graph ~ count_graph + C(General) + poly(pop, 2), data = data)
clustered_se <- vcovHC(ols3, type = "HC1", cluster = "General")
summary(ols3, vcov = clustered_se)

ols4 <- lm(real_graph ~ count_graph + C(General) + border + poly(pop, 2) + I(crimea_dist < 1000), data = data)
clustered_se <- vcovHC(ols4, type = "HC1", cluster = "General")
summary(ols4, vcov = clustered_se)

m_iv <- ivreg(urban ~  C(General) + border + poly(pop, 2) + I(crimea_dist < 1000) | real_graph |
                count_graph, data = data)
clustered_se <- vcovHC(m_iv, type = "HC1", cluster = "General")

summary(m_iv, vcov = clustered_se)

library(stargazer)

star.out.1 <- stargazer(ols1, ols2, ols3, ols4, m_iv)

stargazer(m_iv, keep.stat = "n")

summary_data = data[, c('ALL', 'CITY', 'agr_output', 'ind', 'urban')]
summary_data['ALL'] = summary_data['ALL'] / 1000
summary_data['CITY'] = summary_data['CITY'] / 1000
summary_data['agr_output'] = summary_data['agr_output'] / 1000
summary_data['ind'] = summary_data['ind'] / 1000
summary_data['urban'] = summary_data['urban'] * 100

stargazer(summary_data,
          title="Descriptive statistics", digits=4, median = TRUE,
          iqr = TRUE)
