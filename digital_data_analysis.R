df_original <- read.csv("working_population_health_data.csv", header=T, sep=",")
df <- df_original
head(df)

# 定義變數意義
ageKey <- c("2"="15-19歲", "3"="20-29歲", "4"="30-39歲", "5"="40-49歲", "6"="50-59歲", "7"="60-69歲", "8"="60-69歲")
df$v4 <- ageKey[as.character(df$v4)]
df$v4_original <- df_original$v4

genderKey <- c("1"="男性", "2"="女性")
df$v45 <- genderKey[as.character(df$v45)]
df$v45_original <- df_original$v45

# 設定字型
library(showtext)
font_add_google("Noto Sans TC", "NotoSansTC")
font_families()
showtext_auto(enable=TRUE)
par(family = "Noto Sans TC")

# 描述性統計
library(ggplot2)
theme_set(theme_bw())

# 年齡分佈
ageDist <- data.frame(table(Age = df$v4))
print("年齡分佈\n")
print(ageDist)
ageGraph <- ggplot(ageDist, aes(x = Age, y = Freq)) + 
  geom_col() + 
  labs(title = "年齡分佈", x = "年齡", y = "樣本數") +
  geom_text(aes(label = Freq), vjust = -0.2, size = 3)
ageGraph

# 性別分佈
genderDist <- data.frame(table(Gender = df$v45))
genderDist$Percentage = genderDist$Freq / sum(genderDist$Freq)
genderDist

# 遠距工作比例
remoteDist <- data.frame(table(df$v24))
names(remoteDist) <- c("Remote_3months", "Freq")
remoteDist

remoteGraph <- ggplot(remoteDist, aes(x=Remote_3months, y=Freq)) + 
  geom_col() +
  labs(x = "最近三個月是否使用網路從事遠距工作", y = "樣本數") +
  geom_text(aes(label = Freq), vjust = -0.2, size = 3)
remoteGraph

## 遠距工作比例 - 依照年齡區分
df24 <- df[df$v24 == "1", ]
dist <- data.frame(table(Remote = df24$v24, Age = df24$v4))
dist$Percent <- dist$Freq / ageDist$Freq
dist


# 工作內容使用網路
netDist <- data.frame(Percentage = df$v41, Age = df$v4, Gender = df$v45)
netDist
ggplot(netDist, aes(x = Age, y = Percentage, fill = Age)) +
  geom_boxplot(fill = "white") +
  labs(title = "工作內容使用電腦或網路才能完成的比例", 
       x = '年齡', y = '比例 %')
  
# 下班後處理工作
balanceDist <- data.frame(table(df$v43))
names(balanceDist) <- c("Balance", "Freq")
balanceDist

## 下班後處理工作 - 依照年齡區分
df43 <- df[df$v43 == "1", ]
dist <- data.frame(table(Balance = df43$v43, Age = df43$v4))
dist$Percentage <- dist$Freq / ageDist$Freq
dist

ggplot(dist, aes(x = Age, y = Percentage)) + 
  geom_col(fill="#a4c8e1", width = 0.7) +
  labs(title = "下班後仍需處理工作的比例(以年齡分組)", x = "年齡", y = "比例 %")


# 被人工智慧取代的焦慮
aiDist <- data.frame(table(Ai = df$v42))

ggplot(aiDist, aes(x = Ai, y = Freq, fill = Ai)) + 
  geom_col(fill="#a4c8e1") +
  labs(x = "被人工智慧取代的焦慮 (1: 非常可能  4: 完全不可能)", y = "樣本數") +
  geom_text(aes(label = Freq), vjust = -0.2, size = 3)


# 身體狀況
phyDist <- data.frame(table(Physical = df$v33))

ggplot(phyDist, aes(x = Physical, y = Freq)) + 
  geom_col(fill="#a4c8e1", width = 0.7) +
  labs(x = "身體狀況變差 (1: 差很多 5: 變好很多)", y = "樣本數") +
  geom_text(aes(label = Freq), vjust = -0.2, size = 3)


# 多元回歸模型
library(ppcor)
library(stargazer)

# 主觀幸福感
head(df)
model1 <- lm(v34 ~ v24 + v41 + v43 + v42 + v33 + v45 + v8 + v38, data = df[df$v4 == '15-19歲',])
model2 <- lm(v34 ~ v24 + v41 + v43 + v42 + v33 + v45 + v8 + v38, data = df[df$v4 == '20-29歲',])
model3 <- lm(v34 ~ v24 + v41 + v43 + v42 + v33 + v45 + v8 + v38, data = df[df$v4 == '30-39歲',])
model4 <- lm(v34 ~ v24 + v41 + v43 + v42 + v33 + v45 + v8 + v38, data = df[df$v4 == '40-49歲',])
model5 <- lm(v34 ~ v24 + v41 + v43 + v42 + v33 + v45 + v8 + v38, data = df[df$v4 == '50-59歲',])
model6 <- lm(v34 ~ v24 + v41 + v43 + v42 + v33 + v45 + v8 + v38, data = df[df$v4 == '60-69歲',])

stargazer(model1, model2, model3, type="text", align=TRUE, no.space=TRUE, 
          column.labels = c("15-19歲", "20-29歲", "30-39歲"))

stargazer(model4, model5, model6, type="text", align=TRUE, no.space=TRUE,
          column.labels = c("40-49歲", "50-59歲", "60-69歲"))


# 淨相關: 剔除其他變數影響後，兩個變數間的真實關聯
round(pcor(df_original[c(3, 4, 5, 6, 7, 2, 9, 10, 8)])$estimate, 03) 
round(pcor(df_original[c(3, 4, 5, 6, 7, 2, 9, 10, 8)])$p.value, 03) 

# 半淨相關: 衡量特定自變數對依變數的獨特貢獻
round(spcor(df_original[c(3, 4, 5, 6, 7, 2, 9, 10, 8)])$estimate, 03) 
round(spcor(df_original[c(3, 4, 5, 6, 7, 2, 9, 10, 8)])$p.value, 03) 
