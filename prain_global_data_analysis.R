rm(list=ls())

library("openxlsx")
library(dplyr)
library(ggplot2)
library(DataComputing)
library(dummies)
library(lubridate)
library(extrafont)
library(plotrix)
#################################################################################
########################## 데이터 읽어들이기. 원래 데이터로 읽힘: 데이터명 "prain"
prain <- read.xlsx("/Users/jeongseohyeong/Desktop/Summer 18/Bigdata Project/saleslist(original).xlsx")


#################################################################################
############################ 1. 접수내용에서 제안서 제출마감, 전자 입찰마감일 추출

# 제안서 제출마감 : 0000. 00. 00
# 전자 입찰마감 : 0000. 00. 00

prain_접수내용 <- prain[, c(1,2,7)]

## 만약 다르면, 제안서 제출마감
test2 <- prain_접수내용 %>% 
  extractMatches("[ㄱ-힣]{3} [ㄱ-힣]{2} ?[ㄱ-힣]{2}? ?:? ?([0-9]{4}. ?[0-9]{1,2}. ?[0-9]{1,2})", 
                 접수내용, 제안서마감 = 1)

## 만약 다르면, 전자 입찰마감
test2 <- test2 %>% 
  extractMatches("[ㄱ-힣]{2} [ㄱ-힣]{2} ?[ㄱ-힣]{2} ?:? ?([0-9]{4}. ?[0-9]{1,2}. ?[0-9]{1,2})", 
                 접수내용, 전자입찰마감 = 1)

# 몇 개나 채워졌는지 확인
sum(is.na(test$마감일))
sum(is.na(test2$제안서마감))
sum(is.na(test2$전자입찰마감))

# 안채워진것 가져와서 패턴분석
test2_제안서마감 <- test2 %>% filter(is.na(제안서마감))
test2_전자입찰마감 <- test2 %>% filter(is.na(전자입찰마감))

test2_제안서마감 <- test2_제안서마감[, 1:3] %>% 
  extractMatches("마감 ?:? ?([0-9]{4}. ?[0-9]{1,2}. ?[0-9]{1,2})", 
                 접수내용, 제안서마감 = 1)

# 몇 개나 채워졌는지 확인
sum(!is.na(test2_제안서마감$제안서마감))

# 채워진만큼 test2에다 채우기

test2$제안서마감 <- as.character(test2$제안서마감)
for (i in 1:nrow(test2_제안서마감)){
  if (!is.na(test2_제안서마감$제안서마감[i])){
    original_value <- as.character(test2_제안서마감[i, 3]) # 이 값을 changed에 가져가서 비교하는 것
    wanted_value <- as.character(test2_제안서마감[i, 4])
    test2$제안서마감 <- as.character(test2$제안서마감)
    test2$제안서마감[test2$접수내용 == original_value] <- wanted_value
  }
}
test2$제안서마감 <- as.factor(test2$제안서마감)


sum(is.na(test2$제안서마감))

######################################################
###################################################### 반복해서 패턴분석

test2_제안서마감 <- test2 %>% filter(is.na(제안서마감))

sum(!is.na(test2_제안서마감$제안서마감))

test2_제안서마감 <- test2_제안서마감[, 1:3] %>% 
  extractMatches("마감 : ([0-9]{4}.?[0-9]{1,2}.?[0-9]{1,2})",  #패턴바꿔가며 입력
                 접수내용, 제안서마감 = 1)

hmm <- test2_제안서마감 %>% filter(!is.na(제안서마감))

# 몇 개나 채워졌는지 확인
sum(!is.na(test2_제안서마감$제안서마감))

sum(is.na(test2$제안서마감)) #이 갯수에서 위에 갯수만큼 줄어야 함.

#test2_제안서마감 <- test2_제안서마감[-c(1263, 1591, 3050), ]

# 채워진만큼 test2에다 채우기
test2$제안서마감 <- as.character(test2$제안서마감)
for (i in 1:nrow(test2_제안서마감)){
  if (!is.na(test2_제안서마감$제안서마감[i])){
    original_value <- as.character(test2_제안서마감[i, 3]) # 이 값을 changed에 가져가서 비교하는 것
    wanted_value <- as.character(test2_제안서마감[i, 4])
    test2$제안서마감 <- as.character(test2$제안서마감)
    test2$제안서마감[test2$접수내용 == original_value] <- wanted_value
  }
}
test2$제안서마감 <- as.factor(test2$제안서마감)

sum(is.na(test2$제안서마감))

######################################################
######################################################

sum(is.na(test2$제안서마감))

saleslist_deadline <- test2[ ,-5]
colnames(saleslist_deadline)[4] <- "마감일자"

### csv 인코딩: CP949로 저장
write.csv(saleslist_deadline, file="/Users/jeongseohyeong/Desktop/Summer 18/Bigdata Project/saleslist_deadline.csv",
          fileEncoding = "CP949")

#################################################################################
################################################### NA값만 추출해서 나누기


# 엑셀이 안읽힘


#################################################################################
################################################### 2. 문의 일자 변수 ~ 결과 변수
rm(list=ls())

library("openxlsx")
library(dplyr)
library(ggplot2)
library(DataComputing)
#################################################################################
########################## 데이터 읽어들이기. 원래 데이터로 읽힘: 데이터명 "prain"
pg <- read.xlsx("/Users/jeongseohyeong/Desktop/Summer 18/Bigdata Project/pg_8_1.xlsx")

# NA 값 하나 있음: drop, ing, success, cancleed, failed, holding (6가지 카테고리)
unique(pg$결과)

prain_문의일자 <- pg[, c(1,2,3,20)]



# NA 값 두 개 있는 곳에 기타 넣음
prain_문의일자$산업군[is.na(prain_문의일자$산업군)] <- "기타"
sum(is.na(prain_문의일자$산업군))

prain_문의일자$문의일자_전체 <- as.Date(strptime(prain_문의일자$문의일자, "%Y-%m-%d"))
prain_문의일자$문의일자_월 <- format(as.Date(prain_문의일자$문의일자), "%Y-%m")

# making dummy for 결과변수: drop, ing, success, cancelled, failed, holding, NA
# 4143 IB스포츠 결과변수 NA 삭제
prain_문의일자 <- prain_문의일자 %>% filter(!is.na(결과))

prain_문의일자 <- cbind(prain_문의일자, dummy(prain_문의일자$결과, sep = "_"))

# group by: 문의일자_월 -> 전체 건수
문의건수_a <- prain_문의일자 %>% group_by(문의일자_월) %>%
  summarise(응답수=n())

# group by: 문의일자_월, 결과
문의건수_결과별 <- prain_문의일자 %>% group_by(문의일자_월, 결과) %>%
  summarise(응답수=n())

# "success"   "cancelled" "drop"      "failed"    "holding"   "ing"  
test <- 문의건수_결과별 %>% filter(결과 == "ing")

result <- c()

for (i in 1:nrow(문의건수)) {
  original_value <- as.character(문의건수[i, 1])
  wanted_value <- test$응답수[as.character(test$문의일자_월) == original_value]
  if (length(wanted_value) != 0){
    result <- c(result, wanted_value)
  }
  else {
    result <- c(result, 0)
  }
}

문의건수 <- cbind(문의건수, result)

# colnames 정리
colnames(문의건수)[3] <- "success"
colnames(문의건수)[4] <- "cancelled"
colnames(문의건수)[5] <- "drop"
colnames(문의건수)[6] <- "failed"
colnames(문의건수)[7] <- "holding"
colnames(문의건수)[8] <- "ing"

# 결과변수 비율로 정리하기
문의건수 <- 문의건수 %>% mutate(success_rate = round(success/응답수 * 100, 2))
문의건수 <- 문의건수 %>% mutate(cancelled_rate = round(cancelled/응답수 * 100, 2))
문의건수 <- 문의건수 %>% mutate(drop_rate = round(drop/응답수 * 100, 2))
문의건수 <- 문의건수 %>% mutate(failed_rate = round(failed/응답수 * 100, 2))
문의건수 <- 문의건수 %>% mutate(holding_rate = round(holding/응답수 * 100, 2))
문의건수 <- 문의건수 %>% mutate(ing_rate = round(ing/응답수 * 100, 2))

write.csv(문의건수, file="/Users/jeongseohyeong/Desktop/Summer 18/Bigdata Project/saleslist_문의건수.csv")
write.csv(문의건수, file="/Users/jeongseohyeong/Desktop/Summer 18/Bigdata Project/saleslist_문의건수_인코딩.csv",
          fileEncoding = "CP949")

# visualization
문의건수$문의일자_월 <- 문의건수_a$문의일자_월
문의건수$문의일자 <- as.Date(paste(문의건수$문의일자_월,"-01",sep="")) # date format 억지로 맞춤

# 결과변수 6개의 비율을 확인 in percent
p1 <- ggplot(문의건수, aes(x=문의일자)) +
  geom_point(aes(y=success_rate, color = "success rate"), size = 2, alpha = 0.6) +
  geom_line(aes(y=success_rate,, color = "success rate"), alpha = 0.7, size = 0.3) +
  
  geom_point(aes(y=cancelled_rate, color = "cancelled rate"), size = 2, alpha = 0.6) +
  geom_line(aes(y=cancelled_rate, color = "cancelled rate"), alpha = 0.7, size = 0.3) +
  
  geom_point(aes(y=failed_rate, color = "failed rate"), size = 2, alpha = 0.6) +
  geom_line(aes(y=failed_rate, color = "failed rate"), alpha = 0.7, size = 0.3) +
  
  geom_point(aes(y=drop_rate, color = "drop rate"), size = 2, alpha = 0.6) +
  geom_line(aes(y=drop_rate, color = "drop rate"), alpha = 0.7, size = 0.3) +
  
  geom_point(aes(y=holding_rate, color = "holding rate"), size = 2, alpha = 0.6) +
  geom_line(aes(y=holding_rate, color = "holding rate"), alpha = 0.7, size = 0.3) +
  
  geom_point(aes(y=ing_rate, color = "ing rate"), size = 2, alpha = 0.6) +
  geom_line(aes(y=ing_rate, color = "ing rate"), alpha = 0.7, size = 0.3)


# 2007년 하나 성공 케이스를 제외한 success와 fail 비율 확인
p2 <- ggplot(문의건수[-1, ], aes(x=문의일자)) + # 2007년 하나 성공 케이스 제외
  geom_point(aes(y=success_rate, color = "success rate"), size = 2, alpha = 0.6) +
  geom_line(aes(y=success_rate,, color = "success rate"), alpha = 0.7, size = 0.3) +
  geom_point(aes(y=failed_rate, color = "failed rate"), size = 2, alpha = 0.6) +
  geom_line(aes(y=failed_rate, color = "failed rate"), alpha = 0.7, size = 0.3)

# 월별 total 문의건수
ggplot(문의건수[-1,], aes(x=문의일자, y=응답수)) +
  geom_bar(fill="dark blue", stat="identity")

######################################################
###################################################### 문의일자 년도별로 나눔
문의건수$년도 <- format(as.Date(문의건수$문의일자, format="%Y-%m-%d"),"%Y")
문의건수$월 <- format(as.Date(문의건수$문의일자, format="%Y-%m-%d"),"%m")

# bar plot 문의건수별 각 년도별 2007년은 생략
p_문의건수 <- ggplot(문의건수[-1,], aes(x=월, y=응답수)) +
  geom_bar(fill="dark blue", stat="identity") +
  facet_wrap(vars(년도)) +
  theme_set(theme_gray(base_family='NanumGothic')) + # 한글 입력
  labs(title = "각 년도별 문의건수", x = "월", y = "문의건수")


library("openxlsx")
library("dplyr")
library("ggplot2")

pg <- read.xlsx("/Users/jeongseohyeong/Desktop/Summer 18/Bigdata Project/pgnn.xlsx")
pgPT <- filter(pg, pg$Bid =="경쟁PT")

# bar plot 각 년도별 success 비율
p_success <- ggplot(문의건수[-1,], aes(x=월, y=success_rate)) +
  geom_bar(fill="deepskyblue3", stat="identity") +
  facet_wrap(vars(년도)) +
  theme_set(theme_gray(base_family='NanumGothic')) + # 한글 입력
  labs(title = "각 년도별 success 비율", x = "월", y = "success rate(%)")

# bar plot 각 년도별 cancelled 비율
p_cancelled <- ggplot(문의건수[-1,], aes(x=월, y=cancelled_rate)) +
  geom_bar(fill="firebrick3", stat="identity") +
  facet_wrap(vars(년도)) +
  theme_set(theme_gray(base_family='NanumGothic')) + # 한글 입력
  labs(title = "각 년도별 cancelled 비율", x = "월", y = "cancelled rate(%)")

# bar plot 각 년도별 drop 비율
p_drop <- ggplot(문의건수[-1,], aes(x=월, y=drop_rate)) +
  geom_bar(fill="goldenrod3", stat="identity") +
  facet_wrap(vars(년도)) +
  theme_set(theme_gray(base_family='NanumGothic')) + # 한글 입력
  labs(title = "각 년도별 drop 비율", x = "월", y = "drop rate(%)")

# bar plot 각 년도별 failed 비율
p_failed <- ggplot(문의건수[-1,], aes(x=월, y=failed_rate)) +
  geom_bar(fill="orangered3", stat="identity") +
  facet_wrap(vars(년도)) +
  theme_set(theme_gray(base_family='NanumGothic')) + # 한글 입력
  labs(title = "각 년도별 failed 비율", x = "월", y = "failed rate(%)")

# bar plot 각 년도별 holding 비율
p_holding <- ggplot(문의건수[-1,], aes(x=월, y=holding_rate)) +
  geom_bar(fill="paleturquoise3", stat="identity") +
  facet_wrap(vars(년도)) +
  theme_set(theme_gray(base_family='NanumGothic')) + # 한글 입력
  labs(title = "각 년도별 holding 비율", x = "월", y = "holding rate(%)")

# bar plot 각 년도별 ing 비율
p_ing <- ggplot(문의건수[-1,], aes(x=월, y=ing_rate)) +
  geom_bar(fill="seagreen3", stat="identity") +
  facet_wrap(vars(년도)) +
  theme_set(theme_gray(base_family='NanumGothic')) + # 한글 입력
  labs(title = "각 년도별 ing 비율", x = "월", y = "ing rate(%)")

p_ing
p_holding
p_failed
p_drop
p_cancelled
p_success

#################################################################################
###########################################시간(월별)에 따른 산업군 분포 변화 보기
#########x축에 시간, y축에는 success count, 그리고 도수분포표에 따른 success count

# 클라이언트의 산업군 분석: NA에 기타 넣음
pg$산업군[is.na(pg$산업군)] <- "기타"
pg$산업군[pg$산업군 == "금육"] <- "금융"
pg$산업군[pg$산업군 == "제조업"] <- "정보기술"

data <- pg %>% 
  group_by(산업군) %>% 
  count() %>% 
  ungroup() %>% 
  mutate(per=`n`/sum(`n`)) %>% 
  arrange(desc(산업군))

data$label <- scales::percent(data$per)

p_산업군 <- ggplot(data = data)+
  geom_bar(aes(x = "", y = per, fill = 산업군), stat = "identity", width = 1) +
  coord_polar("y", start = 0, direction = -1) +
  theme_void()+
  theme_set(theme_gray(base_family = 'NanumGothic')) +
  geom_text(aes(x = 1.2, y = cumsum(per) - per/2, label = label), size = 3) +
  labs(title = "고객 산업군 분석")

p_산업군

# 결과별 비율따라 산업군 분석
prain_산업군 <- pg[, c(1,2,3,20)]
sum(is.na(prain_산업군$결과))

prain_산업군 <- prain_산업군 %>% filter(!is.na(prain_산업군$결과))
sum(is.na(prain_산업군$결과))

## success
data <- pg %>% 
  filter(결과 == "success") %>%
  group_by(산업군) %>% 
  count() %>% 
  ungroup() %>% 
  mutate(per=`n`/sum(`n`)) %>% 
  arrange(desc(산업군))

data$label <- scales::percent(data$per)

p_산업군_success <- ggplot(data = data)+
  geom_bar(aes(x = "", y = per, fill = 산업군), stat = "identity", width = 1) +
  coord_polar("y", start = 0, direction = -1) +
  theme_void()+
  theme_set(theme_gray(base_family = 'NanumGothic')) +
  geom_text(aes(x = 1.2, y = cumsum(per) - per/2, label = label), size = 3) +
  labs(title = "success 고객군 분석")

################################################### 위 pie chart 샘플. 6개 생성 가능
################################################### stacked bar chart로 표현
test <- prain_산업군 %>% group_by(결과, 산업군) %>%
  summarise(응답수=n())

p_결과별산업군갯수 <- ggplot(test, aes(x=test$결과, y=응답수, fill=산업군)) + 
  geom_bar(stat="identity") +
  theme_set(theme_bw(base_family = 'NanumGothic')) +
  labs(title = "결과별 산업군 분석 (단위: 갯수)", x = "\n결과", y = "문의건수\n")
  #theme_bw()

p_결과별산업군갯수

## 결과별 비율 계산 -> rbind()
dat_cancelled <- test %>% filter(결과 == "cancelled") %>% 
  mutate(비율 = round(응답수 / sum(dat_cancelled$응답수) * 100, 2))

dat_drop <- test %>% filter(결과 == "drop") %>% 
  mutate(비율 = round(응답수 / sum(dat_drop$응답수) * 100, 2))

dat_failed <- test %>% filter(결과 == "failed") %>% 
  mutate(비율 = round(응답수 / sum(dat_failed$응답수) * 100, 2))

dat_holding <- test %>% filter(결과 == "holding") %>% 
  mutate(비율 = round(응답수 / sum(dat_holding$응답수) * 100, 2))

dat_ing <- test %>% filter(결과 == "ing") %>% 
  mutate(비율 = round(응답수 / sum(dat_ing$응답수) * 100, 2))

dat_success <- test %>% filter(결과 == "success") %>% 
  mutate(비율 = round(응답수 / sum(dat_success$응답수) * 100, 2))

## rbind()
dat <- rbind(dat_cancelled, dat_drop, dat_failed, dat_holding, dat_ing, dat_success)

## 비율 시각화
p_결과별산업군비율 <- ggplot(dat, aes(x=dat$결과, y=비율, fill=산업군)) + 
  geom_bar(stat="identity") +
  theme_set(theme_bw(base_family = 'NanumGothic')) +
  labs(title = "결과별 산업군 분석 (단위: 갯수)", x = "\n결과", y = "문의비율(%)\n")
#theme_bw()

p_결과별산업군비율



#################################################################################
######################################################################## 마감일자
pg_rep <- read.xlsx("/Users/jeongseohyeong/Desktop/Summer 18/Bigdata Project/pg_데드라인포함.xlsx")

마감일자_na <- pg %>% filter(is.na(마감일자))

마감일자_서형 <- 마감일자_na[1594:2390, ]

write.csv(마감일자_서형, file="/Users/jeongseohyeong/Desktop/Summer 18/Bigdata Project/마감일자_서형.csv",
              fileEncoding = "CP949")

#################################################################################
################################################################## 마감일자 합치기
# library(readxl)
# library(stringr)
# 
# 서형 <- read_excel("/Users/jeongseohyeong/Desktop/Summer 18/Bigdata Project/마감일자_서형.xlsx")
# 
# # 채워진만큼 pg에다 채우기 (서형)
# pg_rep <- pg
# pg <- pg_rep
# # 채우기 전 na 몇 개인지 확인
# sum(is.na(pg$마감일자)) # 서형 채우기 전 3185
# 
# 서형$마감일자 <- as.character(서형$마감일자)
# # 몇 개나 채워질지 확인
# sum(!is.na(서형$마감일자)) # 133개
# 
# for (i in 1:nrow(서형)){
#   if (!is.na(서형$마감일자[i])){
#     original_value <- str_replace_all(as.character(서형[i, 9]), "[\r\n]" ,"")
#     wanted_value <- as.character(서형[i, 10])
#     pg$마감일자 <- as.character(pg$마감일자)
#     pg$마감일자[str_replace_all(pg$접수내용, "[\r\n]" , "") == original_value] <- as.character(wanted_value)
#   }
# }
# 
# #pg$마감일자 <- as.factor(pg$마감일자)
# # 몇 개나 채워졌는지 확인
# sum(is.na(pg$마감일자))
# 
# as.Date(39806, origin = "1899-12-30")

sum(is.na(pg$마감일자))

write.csv(pg, file="/Users/jeongseohyeong/Desktop/Summer 18/Bigdata Project/pg_서형채움.xlsx",
          fileEncoding = "CP949")

pg_마감일자 <- read.xlsx("/Users/jeongseohyeong/Desktop/Summer 18/Bigdata Project/pg_서형채움.xlsx")


## format은 YYYY-mm-dd로. 예를들어 16년 3월 2일이면 "2016-03-02"
sum(is.na(pg_마감일자$마감일자)) #3090

sum(is.na(pg_마감일자[1:1900, ]$마감일자)) #777        -> 경준
sum(is.na(pg_마감일자[1901:3300, ]$마감일자)) #784     -> 영진
sum(is.na(pg_마감일자[3301:4800, ]$마감일자)) #754     -> 서형
sum(is.na(pg_마감일자[4801:5883, ]$마감일자)) #775     -> 현지


#################################################################################
######################################################################## 8월 13일

# 1. (마감일자 – 문의일자) 와 success 보기 : X 변수로 적당한지. 
# 2. (파일명2 있고 없고의 여부) : X 변수로 적당한지 분석.
# 3. (새로운 엑셀) Budget 변수 뽑고 어느 사업 분야가 몇 퍼센트 차지하는지 분석하기 —> 젤 마지막에

rm(list=ls())

library("openxlsx")
library(dplyr)
library(ggplot2)
library(DataComputing)
library(dummies)
library(lubridate)
library(extrafont)
library(plotrix)


prain <- read.xlsx("/Users/jeongseohyeong/Desktop/Summer 18/Bigdata Project/prain (1).xlsx")

prain$마감일자 <- as.Date(as.numeric(prain$마감일자), origin = "1899-12-30")
prain$문의일자 <- as.Date(as.numeric(prain$문의일자), origin = "1899-12-30")

################################################################################
######################################################################## 1.

prain$기간 <- prain$마감일자 - prain$문의일자

###
prain$Budget <- as.numeric(as.character(prain$Budget))
prain$기간 <- as.numeric(as.character(prain$기간))
###

################################################################################
#write.xlsx(prain, file = "/Users/jeongseohyeong/Desktop/Summer 18/Bigdata Project/prain (1).xlsx")

summary(prain$기간)

nrow(prain %>% filter(기간 < 0)) # 21개

test <- prain %>% filter(기간 >= 0)
test <- test %>% filter(기간 <= 50)

success <- prain %>% filter(결과 == "success")
sum(is.na(success$마감일자)) # 성공한 것(1022)들 중에서는 655 missing

drop <- prain %>% filter(결과 == "drop")
sum(is.na(drop$마감일자)) # 3273 중 628개


## assumption: 기간이 짧을 수록 drop하는 경우가 많을 것이다.

# 기간변수의 전체적 분포
test %>% ggplot(aes(x=기간)) +
  geom_density() +
  theme_set(theme_bw(base_family = 'NanumGothic')) +
  labs(title = "마감일까지의 기간 (50일 이하) 분포", x = "마감일까지의 기간")

# 박스플랏
test %>% ggplot(aes(x=결과, y=기간, fill=결과)) +
  geom_boxplot() +
  scale_fill_brewer(palette="Blues") +
  theme_set(theme_classic(base_family = 'NanumGothic')) +
  labs(title = "마감일까지의 기간 따른 결과별 박스플랏", x = "결과", y = "마감일까지의 기간") # 안유의함

# 기간 변수 ~ 결과의 박스플랏과 분포 같이 보기
test %>% ggplot(aes(x=결과, y=기간, fill=결과)) +
  geom_violin(trim=FALSE)+
  geom_boxplot(width=0.5, fill="white") +
  scale_fill_brewer(palette="Blues") +
  theme_set(theme_classic(base_family = 'NanumGothic')) +
  labs(title = "마감일까지의 기간 따른 결과별 케이스 분포", x = "결과", y = "마감일까지의 기간") # 안유의함

## 결과: 그다지 유의하지 않음. 하지만 데이터 다시 채워야 함.
## 1) 12월 1월의 경우 년도 주의.
## 2) 마감일 4일 이라고 되어있는 경우 문의일자가 2016년 12월 31일 인 경우 -> 2017년 1월 4일
## 3) pt마감일, 제안서 마감일로만 채워야. 아무런 날짜, 생사날짜, 의사를 언제까지 밝혀달라, 입찰참가등록, 예산서 마감 (X)
## 4) 마감일시: 2월 10일 ~ 20일 이면 20일로 채워야 함


################################################################################
######################################################################## 2.

prain$`파일명.#1`[is.na(prain$`파일명.#1`)] <- 0
prain$`파일명.#1`[prain$`파일명.#1` != 0] <- 1

prain$`파일명.#2`[is.na(prain$`파일명.#2`)] <- 0
prain$`파일명.#2`[prain$`파일명.#2` != 0] <- 1

prain <- prain %>% mutate(파일 = as.numeric(`파일명.#1`) + as.numeric(`파일명.#2`))
prain$파일 <- as.factor(prain$파일)

# 1) 파일 갯수에 따른 결과변수 분석 (count)
prain_graph <- prain %>% group_by(결과, 파일) %>%
  summarise(응답수=n())

ggplot(prain_graph, aes(x=결과, y=응답수, fill=파일)) + 
  geom_bar(stat="identity") +
  scale_fill_brewer(palette="Blues") +
  theme_set(theme_bw(base_family = 'NanumGothic')) +
  labs(title = "파일 갯수에 따른 결과변수 분석", x = "\n결과", y = "파일갯수\n")



dat_cancelled <- prain_graph %>% filter(결과 == "cancelled") %>% 
  mutate(비율 = round(응답수 / sum(응답수) * 100, 2))

dat_drop <- prain_graph %>% filter(결과 == "drop") %>% 
  mutate(비율 = round(응답수 / sum(응답수) * 100, 2))

dat_failed <- prain_graph %>% filter(결과 == "failed") %>% 
  mutate(비율 = round(응답수 / sum(응답수) * 100, 2))

dat_holding <- prain_graph %>% filter(결과 == "holding") %>% 
  mutate(비율 = round(응답수 / sum(응답수) * 100, 2))

dat_ing <- prain_graph %>% filter(결과 == "ing") %>% 
  mutate(비율 = round(응답수 / sum(응답수) * 100, 2))

dat_success <- prain_graph %>% filter(결과 == "success") %>% 
  mutate(비율 = round(응답수 / sum(응답수) * 100, 2))

## rbind()
dat <- rbind(dat_cancelled, dat_drop, dat_failed, dat_holding, dat_ing, dat_success)

# 2) 파일 갯수에 따른 결과변수 분석 (비율)
ggplot(dat, aes(x=결과, y=비율, fill=파일)) + 
  geom_bar(stat="identity") +
  scale_fill_brewer(palette="Blues") +
  theme_set(theme_bw(base_family = 'NanumGothic')) +
  labs(title = "파일 갯수에 따른 결과변수 분석 (비율)", x = "\n결과", y = "파일갯수\n")


# 3) bid와의 관계 (count)

prain_graph <- prain %>% group_by(Bid, 파일) %>%
  summarise(응답수=n())

ggplot(prain_graph, aes(x=Bid, y=응답수, fill=파일)) + 
  geom_bar(stat="identity") +
  scale_fill_brewer(palette="Blues") +
  theme_set(theme_bw(base_family = 'NanumGothic')) +
  labs(title = "파일 갯수에 따른 Bid변수 분석", x = "\nBid방식", y = "파일갯수\n")


# stacked bar plot

dat_경쟁PT <- prain_graph %>% filter(Bid == "경쟁PT") %>% 
  mutate(비율 = round(응답수 / sum(응답수) * 100, 2))

dat_경쟁회사소개 <- prain_graph %>% filter(Bid == "경쟁회사소개") %>% 
  mutate(비율 = round(응답수 / sum(응답수) * 100, 2))

dat_단독제안 <- prain_graph %>% filter(Bid == "단독제안") %>% 
  mutate(비율 = round(응답수 / sum(응답수) * 100, 2))

dat_기타 <- prain_graph %>% filter(Bid == "기타") %>% 
  mutate(비율 = round(응답수 / sum(응답수) * 100, 2))

dat_수의계약 <- prain_graph %>% filter(Bid == "수의계약") %>% 
  mutate(비율 = round(응답수 / sum(응답수) * 100, 2))


## rbind()
dat <- rbind(dat_경쟁PT, dat_경쟁회사소개, dat_단독제안, dat_기타, dat_수의계약)

# 4) 파일 갯수에 따른 Bid변수 분석 (비율)
ggplot(dat, aes(x=Bid, y=비율, fill=파일)) + 
  geom_bar(stat="identity") +
  scale_fill_brewer(palette="Blues") +
  theme_set(theme_bw(base_family = 'NanumGothic')) +
  labs(title = "파일 갯수에 따른 Bid변수 분석 (비율)", x = "\nBid", y = "파일갯수\n")


library(corrplot)
M <- cor(prain[, c(14,22)])
corrplot(M, method="circle")


################################################################################
######################################################################## 3.

prain_budget <- prain %>% filter(!is.na(Budget)) %>% select(산업군, Budget)

prain_budget$산업군[prain_budget$산업군 == "금육"] <- "금융"

bugetSum <- NULL
산업군 <- unique(prain_budget$산업군)

for(i in 산업군){
  takeOne <- prain_budget %>% filter(산업군 == i)
  takeOne <- takeOne %>% mutate(총합 = sum(Budget))
  takeOne <- takeOne %>% mutate(평균 = 총합 / nrow(takeOne))
  bugetSum <- rbind(bugetSum, takeOne[1, ])
}

# 총합에 평균도 추가해서 보기
budgetSum <- bugetSum[ ,-2] 

# 산업군 별 전체 budget
budgetSum %>% ggplot(aes(x=산업군, y=round(총합, 2), fill = 산업군)) +
  geom_bar(stat="identity") +
  theme_set(theme_bw(base_family = 'NanumGothic')) +
  labs(title = "산업군 별 전체 budget", x = "\n결과", y = "전체 budget\n")

# 산업군 별 평균 budget
budgetSum %>% ggplot(aes(x=산업군, y=round(평균, 2), fill = 산업군)) +
  geom_bar(stat="identity") +
  theme_set(theme_bw(base_family = 'NanumGothic')) +
  labs(title = "산업군 별 평균 budget", x = "\n결과", y = "평균 budget\n")

# budget의 전체 분포, 결과별 분포
prain %>% filter(!is.na(Budget)) %>%
  ggplot(aes(x=as.numeric(Budget), color = 결과)) +
  geom_density() + 
  xlim(0, 20) +
  theme_set(theme_bw(base_family = 'NanumGothic')) +
  labs(title = "결과별 budget", x = "\nbudget", y = "density\n")
  ## 우측 tail이 너무 길어서 변환해서 보면,

prain %>% filter(!is.na(Budget)) %>%
  ggplot(aes(x=log(as.numeric(Budget)), color = 결과)) +
  geom_density() + 
  theme_set(theme_bw(base_family = 'NanumGothic')) +
  labs(title = "결과별 budget", x = "\nlog(budget)", y = "density\n")

# 결과별 budget의 박스플롯
prain %>% filter(!is.na(Budget)) %>%
  ggplot(aes(x=결과, y=as.numeric(Budget), color = 결과)) +
  geom_boxplot() + 
  ylim(0, 20) +
  theme_set(theme_bw(base_family = 'NanumGothic')) +
  labs(title = "결과별 budget의 박스플롯", x = "\n결과", y = "budget\n")


# Budget/계약기간추출 분석
budget계약기간 <- prain %>% filter(!is.na(Budget))
budget계약기간 <- budget계약기간 %>% filter(!is.na(계약기간))

계약기간추출 <- as.numeric(gsub("[^\\d]+", "", budget계약기간$계약기간, perl=TRUE))
budget계약기간 <- cbind(budget계약기간, 계약기간추출)

budget계약기간<- budget계약기간 %>% mutate(평균Budget = Budget/계약기간추출)

# 결과별 평균 budget의 박스플롯
budget계약기간 %>%
  ggplot(aes(x=결과, y=round(평균Budget, 2), color = 결과)) +
  geom_boxplot() + 
  ylim(0, 1) +
  theme_set(theme_bw(base_family = 'NanumGothic')) +
  labs(title = "결과별 budget의 박스플롯", x = "\n결과", y = "budget/계약기간\n")

# 버짓 시기별
prain %>% ggplot(aes(x=문의일자, y=Budget)) +
  geom_point(size = 0.2, color = "grey", alpha = 0.7) +
  ylim(0, 10) +
  geom_smooth(method = "lm", se = FALSE)

budget계약기간 %>% ggplot(aes(x=문의일자, y=round(평균Budget, 2))) +
  geom_point(size = 0.2, color = "grey", alpha = 0.7) +
  ylim(0, 10) +
  geom_smooth(method = "lm", se = FALSE)  


## 추가: Bid랑 결과변수

prain_1 <- prain %>% group_by(Bid, 결과) %>%
  summarise(응답수=n())

dat_경쟁PT <- prain_1 %>% filter(Bid == "경쟁PT") %>% 
  mutate(비율 = round(응답수 / sum(응답수) * 100, 2))

dat_경쟁회사소개 <- prain_1 %>% filter(Bid == "경쟁회사소개") %>% 
  mutate(비율 = round(응답수 / sum(응답수) * 100, 2))

dat_기타 <- prain_1 %>% filter(Bid == "기타") %>% 
  mutate(비율 = round(응답수 / sum(응답수) * 100, 2))

dat_단독제안 <- prain_1 %>% filter(Bid == "단독제안") %>% 
  mutate(비율 = round(응답수 / sum(응답수) * 100, 2))

dat_수의계약 <- prain_1 %>% filter(Bid == "수의계약") %>% 
  mutate(비율 = round(응답수 / sum(응답수) * 100, 2))


## rbind()
dat <- rbind(dat_경쟁PT, dat_경쟁회사소개, dat_단독제안, dat_기타, dat_수의계약)

# 2) 파일 갯수에 따른 결과변수 분석 (비율)
ggplot(dat, aes(x=Bid, y=비율, fill=결과)) + 
  geom_bar(stat="identity") +
  scale_fill_brewer(palette="Blues") +
  theme_set(theme_bw(base_family = 'NanumGothic')) +
  labs(title = "Bid에 따른 결과변수 분석 (비율)", x = "\nBid", y = "결과\n")


## 추가: 채널과 결과

prain_2 <- prain %>% group_by(채널, 결과) %>%
  summarise(응답수=n())

dat_입찰 <- prain_2 %>% filter(채널 == "입찰") %>% 
  mutate(비율 = round(응답수 / sum(응답수) * 100, 2))

dat_지인 <- prain_2 %>% filter(채널 == "지인") %>% 
  mutate(비율 = round(응답수 / sum(응답수) * 100, 2))

dat_홍보 <- prain_2 %>% filter(채널 == "홍보") %>% 
  mutate(비율 = round(응답수 / sum(응답수) * 100, 2))



## rbind()
dat <- rbind(dat_입찰, dat_지인, dat_홍보)

# 2) 파일 갯수에 따른 결과변수 분석 (비율)
ggplot(dat, aes(x=채널, y=비율, fill=결과)) + 
  geom_bar(stat="identity") +
  #scale_fill_brewer(palette="Blues") +
  theme_set(theme_bw(base_family = 'NanumGothic')) +
  labs(title = "채널에 따른 결과변수 분석 (비율)", x = "\n채널", y = "결과\n")

save <- prain$파일

write.csv(save, file="/Users/jeongseohyeong/Desktop/Summer 18/Bigdata Project/파일.csv",
          fileEncoding = "CP949")


pg <- read.xlsx("/Users/jeongseohyeong/Desktop/형pg_서.xlsx")

pg$마감일자 <- as.Date(as.numeric(pg$마감일자), origin = "1899-12-30")
pg$문의일자 <- as.Date(pg$문의일자, origin = "1899-12-30")

pg$기간 <- pg$마감일자 - pg$문의일자

###
pg$기간 <- as.numeric(as.character(pg$기간))
기간 <- pg$기간
write.csv(기간, file="/Users/jeongseohyeong/Desktop/기간.csv")



######## 8월 22일 수요일
# 문의일자에 년도 새로 뽑아서 새로 변수 만들기
# 기간 변수 새로 추가
# 어느 분야에서는 강하고 어느 분야에서는 약한지. 나머지 6개 결과별로도 산업군 분석하기. 

pg <- read.xlsx("/Users/jeongseohyeong/Desktop/Summer 18/Bigdata Project/pg.xlsx")

pg$산업군 <- as.factor(pg$산업군)
pg$마감일자 <- as.Date(pg$마감일자, origin = "1899-12-30")
pg$문의일자 <- as.Date(pg$문의일자, origin = "1899-12-30")
pg$채널 <- as.factor(pg$채널)
pg$Budget <- as.numeric(pg$Budget)
pg$계약기간 <- as.numeric(pg$계약기간)
pg$Bid <- as.factor(pg$Bid)
pg$결과 <- as.factor(pg$결과)
str(pg)


###################################################### 1. 기간 변수 새로 만들기
######################################################
pg$기간 <- pg$마감일자 - pg$문의일자
pg$기간 <- as.numeric(as.character(pg$기간))

summary(pg$기간) ##.... 여전히 안고쳐진거 있음
index <- seq(from = 1, to = 5883, by = 1)

pg <- cbind(index, pg)

기간 <- pg$기간
write.csv(기간, file="/Users/jeongseohyeong/Desktop/기간.csv")

write.csv(index, file="/Users/jeongseohyeong/Desktop/index.csv")

## index이거 보고 다시 고치기
rePositive <- pg %>% filter(기간 > 70)
reNegative <- pg %>% filter(기간 < -20)

###################################################### 2. 문의일자 년,월 추출
######################################################
pg$문의일자 <- as.character(pg$문의일자)
pg <- pg %>% 
  extractMatches("([0-9]{4})-[0-9]{2}-[0-9]{2}", 
                 문의일자, 문의년도 = 1)

pg <- pg %>% 
  extractMatches("[0-9]{4}-([0-9]{2})-[0-9]{2}", 
                 문의일자, 문의월 = 1)

문의년도 <- pg$문의년도
write.csv(문의년도, file="/Users/jeongseohyeong/Desktop/문의년도.csv")

문의월 <- pg$문의월
write.csv(문의월, file="/Users/jeongseohyeong/Desktop/문의월.csv")


###################################################### 3. 어느 분야에서는 강하고 어느 분야에서는 약한지
###################################################### 나머지 6개 결과별로도 산업군 분석

# 결과별 비율따라 산업군 분석
prain_산업군 <- pg[, c(3,19)]
sum(is.na(prain_산업군$결과))

prain_산업군 <- prain_산업군 %>% filter(!is.na(prain_산업군$결과))
sum(is.na(prain_산업군$결과))

## success
data <- prain_산업군 %>% 
  filter(결과 == "success") %>%
  group_by(산업군) %>% 
  count() %>% 
  ungroup() %>% 
  mutate(per=`n`/sum(`n`)) %>% 
  arrange(desc(산업군))

data$label <- scales::percent(data$per)

p_산업군_success <- ggplot(data = data)+
  geom_bar(aes(x = "", y = per, fill = 산업군), stat = "identity", width = 1) +
  coord_polar("y", start = 0, direction = -1) +
  theme_void()+
  theme_set(theme_gray(base_family = 'NanumGothic')) +
  geom_text(aes(x = 1.2, y = cumsum(per) - per/2, label = label), size = 3) +
  labs(title = "success 고객군 분석")

## cancelled
data <- prain_산업군 %>% 
  filter(결과 == "cancelled") %>%
  group_by(산업군) %>% 
  count() %>% 
  ungroup() %>% 
  mutate(per=`n`/sum(`n`)) %>% 
  arrange(desc(산업군))

data$label <- scales::percent(data$per)

p_산업군_cancelled <- ggplot(data = data)+
  geom_bar(aes(x = "", y = per, fill = 산업군), stat = "identity", width = 1) +
  coord_polar("y", start = 0, direction = -1) +
  theme_void()+
  theme_set(theme_gray(base_family = 'NanumGothic')) +
  geom_text(aes(x = 1.2, y = cumsum(per) - per/2, label = label), size = 3) +
  labs(title = "cancelled 고객군 분석")

## drop
data <- prain_산업군 %>% 
  filter(결과 == "drop") %>%
  group_by(산업군) %>% 
  count() %>% 
  ungroup() %>% 
  mutate(per=`n`/sum(`n`)) %>% 
  arrange(desc(산업군))

data$label <- scales::percent(data$per)

p_산업군_drop <- ggplot(data = data)+
  geom_bar(aes(x = "", y = per, fill = 산업군), stat = "identity", width = 1) +
  coord_polar("y", start = 0, direction = -1) +
  theme_void()+
  theme_set(theme_gray(base_family = 'NanumGothic')) +
  geom_text(aes(x = 1.2, y = cumsum(per) - per/2, label = label), size = 3) +
  labs(title = "drop 고객군 분석")

## failed, holding, ing
data <- prain_산업군 %>% 
  filter(결과 == "failed") %>%
  group_by(산업군) %>% 
  count() %>% 
  ungroup() %>% 
  mutate(per=`n`/sum(`n`)) %>% 
  arrange(desc(산업군))

data$label <- scales::percent(data$per)

p_산업군_failed <- ggplot(data = data)+
  geom_bar(aes(x = "", y = per, fill = 산업군), stat = "identity", width = 1) +
  coord_polar("y", start = 0, direction = -1) +
  theme_void()+
  theme_set(theme_gray(base_family = 'NanumGothic')) +
  geom_text(aes(x = 1.2, y = cumsum(per) - per/2, label = label), size = 3) +
  labs(title = "failed 고객군 분석")

## holding, ing
data <- prain_산업군 %>% 
  filter(결과 == "holding") %>%
  group_by(산업군) %>% 
  count() %>% 
  ungroup() %>% 
  mutate(per=`n`/sum(`n`)) %>% 
  arrange(desc(산업군))

data$label <- scales::percent(data$per)

p_산업군_holding <- ggplot(data = data)+
  geom_bar(aes(x = "", y = per, fill = 산업군), stat = "identity", width = 1) +
  coord_polar("y", start = 0, direction = -1) +
  theme_void()+
  theme_set(theme_gray(base_family = 'NanumGothic')) +
  geom_text(aes(x = 1.2, y = cumsum(per) - per/2, label = label), size = 3) +
  labs(title = "holding 고객군 분석")


## ing
data <- prain_산업군 %>% 
  filter(결과 == "ing") %>%
  group_by(산업군) %>% 
  count() %>% 
  ungroup() %>% 
  mutate(per=`n`/sum(`n`)) %>% 
  arrange(desc(산업군))

data$label <- scales::percent(data$per)

p_산업군_ing <- ggplot(data = data)+
  geom_bar(aes(x = "", y = per, fill = 산업군), stat = "identity", width = 1) +
  coord_polar("y", start = 0, direction = -1) +
  theme_void()+
  theme_set(theme_gray(base_family = 'NanumGothic')) +
  geom_text(aes(x = 1.2, y = cumsum(per) - per/2, label = label), size = 3) +
  labs(title = "ing 고객군 분석")

library(gridExtra)
grid.arrange(grobs = list(p_산업군_success, p_산업군_failed), ncol = 2)
grid.arrange(grobs = list(p_산업군_drop, p_산업군_cancelled), ncol = 2)
grid.arrange(grobs = list(p_산업군_holding, p_산업군_ing), ncol = 2)

#p_산업군_drop, p_산업군_cancelled, p_산업군_holding, p_산업군_ing


############################################################################### 기간변수
test <- pg %>% filter(기간 >= 0)
test <- test %>% filter(기간 < 70)

# 기간변수의 전체적 분포
test %>% ggplot(aes(x=기간)) +
  geom_density() +
  theme_set(theme_bw(base_family = 'NanumGothic')) +
  labs(title = "마감일까지의 기간 분포", x = "마감일까지의 기간")

# 박스플랏
test %>% ggplot(aes(x=결과, y=기간, fill=결과)) +
  geom_boxplot() +
  scale_fill_brewer(palette="Blues") +
  theme_set(theme_classic(base_family = 'NanumGothic')) +
  labs(title = "마감일까지의 기간 따른 결과별 박스플랏", x = "결과", y = "마감일까지의 기간") # 안유의함

# 기간 변수 ~ 결과의 박스플랏과 분포 같이 보기
test %>% ggplot(aes(x=결과, y=기간, fill=결과)) +
  geom_violin(trim=FALSE)+
  geom_boxplot(width=0.5, fill="white") +
  scale_fill_brewer(palette="Blues") +
  theme_set(theme_classic(base_family = 'NanumGothic')) +
  labs(title = "마감일까지의 기간 따른 결과별 케이스 분포", x = "결과", y = "마감일까지의 기간") # 안유의함


#####
reNegative <- reNegative[,c(1:5,23)]
rePositive <- rePositive[,c(1:5,23)]





######## 8월 27일 화요일
pg <- read.xlsx("/Users/jeongseohyeong/Desktop/Summer 18/Bigdata Project/pg.xlsx")

pg$산업군 <- as.factor(pg$산업군)
pg$마감일자 <- as.Date(pg$마감일자, origin = "1899-12-30")
pg$문의일자 <- as.Date(pg$문의일자, origin = "1899-12-30")
#pg$채널 <- as.factor(pg$채널)
pg$Budget <- as.numeric(pg$Budget)
pg$계약기간 <- as.numeric(pg$계약기간)
pg$Bid <- as.factor(pg$Bid)
pg$결과 <- as.factor(pg$결과)
str(pg)

pg_selected <- pg[, c(2,5:11,17,18,20,23)]


### 3) cramer's v heatmap between categorical variable

library(data.table) # data mgmt
library(gtools) # combination

cramer <- pg %>% select(산업군, 파일, 분기, Bid, 결과)
cramer$파일 <- as.factor(cramer$파일)
cramer$분기 <- as.factor(cramer$분기)

cat_var <- colnames(cramer)

# Function to compute Cramer's V
cv.test = function(x,y) {
  CV = sqrt(chisq.test(x, y, correct=FALSE)$statistic /
              (length(x)[1] * (min(length(unique(x))[1],length(unique(y))[1]) - 1)))
  return(as.numeric(CV))
}

# Apply the function to the combination of categorical variable
v_cramer_all <- function(cat_var, df){
  cat_var_grid <- data.table(combinations(n = length(cat_var), r = 2, v = cat_var, repeats.allowed = FALSE))
  
  do.call(rbind,
          apply(cat_var_grid, 1, function(x){
            tmp <- as.character(x)
            vec1 <- unlist(df[tmp[1]])
            vec2 <- unlist(df[tmp[2]])
            
            data.table(
              variable_x = tmp[1],
              variable_y = tmp[2],
              chi2 = chisq.test(x = vec1, vec2, correct=FALSE)$p.value,
              v_cramer = cv.test(x = vec1, y = vec2)
            )
          }))
  
}

results <- v_cramer_all(cat_var = cat_var, df = cramer)


### 4) correlation between numerical variables

#NA 없애고 해야

# Heatmap vizualisation with ggplot2  -------------------------------------

g <- ggplot(results, aes(variable_x, variable_y)) +
  geom_tile(aes(fill = v_cramer), colour = "black") +
  theme(axis.text.x=element_text(angle=45, hjust=1)) +
  scale_fill_gradient(low = "white", high = "steelblue") +
  theme_set(theme_gray(base_family = 'NanumGothic')) +
  xlab(NULL) + ylab(NULL) + theme(axis.text.x=element_text(angle = -90, hjust = 0)) +
  ggtitle("Cramer's V heatmap")

## Cramér's V varies from 0 (corresponding to no association between the variables) 
## to 1 (complete association) and can reach 1 only when the two variables are 
## equal to each other.


### 5) k-means for 기간 na

library(caret)

# na 일단 다 빼기, numeric 변수만 가져가기
k_means_data <- pg_selected %>% filter(!is.na(기간)) %>%
  filter(!is.na(Budget)) %>% filter(!is.na(계약기간))

k_means_data <- k_means_data %>% select(기간, positive_count, negative_count,
                                          Budget, 계약기간, 결과)

# 데이터 스케일링
training_data <- scale(k_means_data[-6])
summary(training_data)

# 모델 빌딩
pg_kmeans = kmeans(training_data, centers = 6, iter.max = 10000)
pg_kmeans$centers

# 결과 확인
k_means_data$cluster<-as.factor(pg_kmeans$cluster)
qplot(기간,계약기간,colour=cluster,data=k_means_data)

# 결과 변수와 비교해서 확인해보기
table(k_means_data$결과, k_means_data$cluster)

### cluster 갯수 정하기

library(NbClust)

nc <- NbClust(training_data, min.nc=2, max.nc=15, method="kmeans")
par(mfrow=c(1,1))
barplot(table(nc$Best.n[1,]),
        xlab="Numer of Clusters", ylab="Number of Criteria",
        main="Number of Clusters Chosen")


wssplot <- function(data, nc=15, seed=1234){
  wss <- (nrow(data)-1)*sum(apply(data,2,var))
  for (i in 2:nc){
    set.seed(seed)
    wss[i] <- sum(kmeans(data, centers=i)$withinss)}
  plot(1:nc, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares")}

wssplot(training_data)

# kmeans로 NA를 채울 수 없음 na가 있으면 클러스터가 결정이 안됨.

# 분기 & 계약기간, 분기 & 산업군

pg %>% ggplot(aes(x=분기, y=계약기간)) +
  geom_boxplot() +
  scale_fill_brewer(palette="Blues") +
  theme_set(theme_classic(base_family = 'NanumGothic')) 
  #+ labs(title = "마감일까지의 기간 따른 결과별 박스플랏", x = "결과", y = "마감일까지의 기간") # 안유의함

pg %>% ggplot(aes(x=산업군, y=계약기간)) +
  geom_boxplot() +
  scale_fill_brewer(palette="Blues") +
  theme_set(theme_classic(base_family = 'NanumGothic')) 

index <- seq(from = 1, to = 5883, by = 1)

pg <- cbind(index, pg)

pg <- read.xlsx("/Users/jeongseohyeong/Desktop/Summer 18/Bigdata Project/pgnn.xlsx")

# 계약기간 imputation 분기 기준으로 가자!
pg %>% filter(분기=="1") %>% select(계약기간) %>% summary() #median: 9
pg %>% filter(분기=="2") %>% select(계약기간) %>% summary() #median: 6
pg %>% filter(분기=="3") %>% select(계약기간) %>% summary() #median: 4
pg %>% filter(분기=="4") %>% select(계약기간) %>% summary() #median: 5

pg$계약기간 <- ifelse(pg$분기=="1" & is.na(pg$계약기간), 9, pg$계약기간)
pg$계약기간 <- ifelse(pg$분기=="2" & is.na(pg$계약기간), 6, pg$계약기간)
pg$계약기간 <- ifelse(pg$분기=="3" & is.na(pg$계약기간), 4, pg$계약기간)
pg$계약기간 <- ifelse(pg$분기=="4" & is.na(pg$계약기간), 5, pg$계약기간)

계약기간 <- pg$계약기간
write.csv(계약기간, file="/Users/jeongseohyeong/Desktop/계약기간.csv")

# budget na 어떻게 채울까
계약기간나누기 <- 계약기간
계약기간나누기[계약기간나누기==0] <- 1

pg <- pg %>% mutate(mean_budget = as.numeric(Budget)/계약기간나누기)

pg %>% ggplot(aes(x=산업군, y=mean_budget)) +
  geom_boxplot() +
  ylim(0, 1) +
  scale_fill_brewer(palette="Blues") +
  theme_set(theme_classic(base_family = 'NanumGothic'))

pg %>% filter(산업군=="건설") %>% select(mean_budget) %>% summary() #median: 0.1192 
pg %>% filter(산업군=="공공기관") %>% select(mean_budget) %>% summary() #median: 0.33636 
pg %>% filter(산업군=="금융") %>% select(mean_budget) %>% summary() #median: 0.15000
pg %>% filter(산업군=="기타") %>% select(mean_budget) %>% summary() #median: 0.4033 
pg %>% filter(산업군=="물류") %>% select(mean_budget) %>% summary() #median: 0.3611
pg %>% filter(산업군=="서비스") %>% select(mean_budget) %>% summary() #median: 0.1667
pg %>% filter(산업군=="에너지") %>% select(mean_budget) %>% summary() #median: 0.2000
pg %>% filter(산업군=="유통") %>% select(mean_budget) %>% summary() #median: 0.1333
pg %>% filter(산업군=="자동차") %>% select(mean_budget) %>% summary() #median: 0.1071
pg %>% filter(산업군=="정보기술") %>% select(mean_budget) %>% summary() #median: 0.1500
pg %>% filter(산업군=="제약") %>% select(mean_budget) %>% summary() #median: 0.16667 
pg %>% filter(산업군=="철강") %>% select(mean_budget) %>% summary() #median: 0.10000


# 산업군으로 채움
pg$mean_budget <- ifelse(pg$산업군=="건설" & is.na(pg$mean_budget), 0.1192, pg$mean_budget)
pg$mean_budget <- ifelse(pg$산업군=="공공기관" & is.na(pg$mean_budget), 0.33636, pg$mean_budget)
pg$mean_budget <- ifelse(pg$산업군=="금융" & is.na(pg$mean_budget), 0.15000, pg$mean_budget)
pg$mean_budget <- ifelse(pg$산업군=="기타" & is.na(pg$mean_budget), 0.4033, pg$mean_budget)
pg$mean_budget <- ifelse(pg$산업군=="물류" & is.na(pg$mean_budget), 0.3611, pg$mean_budget)
pg$mean_budget <- ifelse(pg$산업군=="서비스" & is.na(pg$mean_budget), 0.1667, pg$mean_budget)
pg$mean_budget <- ifelse(pg$산업군=="에너지" & is.na(pg$mean_budget), 0.2000, pg$mean_budget)
pg$mean_budget <- ifelse(pg$산업군=="유통" & is.na(pg$mean_budget), 0.1333, pg$mean_budget)
pg$mean_budget <- ifelse(pg$산업군=="자동차" & is.na(pg$mean_budget), 0.1071, pg$mean_budget)
pg$mean_budget <- ifelse(pg$산업군=="정보기술" & is.na(pg$mean_budget), 0.1500, pg$mean_budget)
pg$mean_budget <- ifelse(pg$산업군=="제약" & is.na(pg$mean_budget), 0.16667, pg$mean_budget)
pg$mean_budget <- ifelse(pg$산업군=="철강" & is.na(pg$mean_budget), 0.10000, pg$mean_budget)

mean_budget <- pg$mean_budget
write.csv(mean_budget, file="/Users/jeongseohyeong/Desktop/mean_budget.csv")

# 기간 na 어떻게 채울까
pg %>% ggplot(aes(x=산업군, y=기간)) +
  geom_boxplot() +
  ylim(0,50) +
  theme_set(theme_classic(base_family = 'NanumGothic'))

기간long <- pg %>% filter(기간 > 12)
기간short <- pg %>% filter(기간 <= 12)

## 그냥 median인 12로 채우는 것이 가장 합리적이라고 생각
pg$기간 <- ifelse(is.na(pg$기간), 12, pg$기간)

## 기간 변수 채운건
기간 <- pg$기간
write.csv(기간, file="/Users/jeongseohyeong/Desktop/기간.csv")

## 최종 선정 변수만 모은 것
pgfinal <- pg %>% select(고객사, 산업군, 기간, 파일, 문의년도, 문의월, 분기, positive_count, 
                            negative_count, 계약기간, mean_budget, Bid, 결과)

pgfinal <- pgfinal %>% filter(!is.na(결과))


## one-way anova test
lm_1 <- lm(계약기간~as.factor(분기), pgfinal)
summary(lm_1)
anova(lm_1)

lm_2 <- lm(mean_budget~as.factor(산업군), pgfinal)
summary(lm_2)
anova(lm_2)

pgraw <- read.xlsx("/Users/jeongseohyeong/Desktop/Summer 18/Bigdata Project/pgnn.xlsx")
lm_01 <- lm(계약기간~as.factor(분기), pgraw)
anova(lm_01)

lm_02 <- lm(mean_budget~as.factor(산업군), pgraw)
anova(lm_02)



pgnn <- read.xlsx("/Users/jeongseohyeong/Desktop/Summer 18/Bigdata Project/pgnn.xlsx")
pgnn$마감일자 <- as.Date(pgnn$마감일자, origin = "1899-12-30")
pgnn$문의일자 <- as.Date(pgnn$문의일자, origin = "1899-12-30")

## correlation plot


## cramer's V









### 5) k-means drop제외한 데이터에 대해서
library(caret)
library(NbClust)

# na 일단 다 빼기, numeric 변수만 가져가기
k_means_data <- pgfinal %>% filter(결과 != "drop")

k_means_data <- k_means_data %>% select(기간, positive_count, negative_count,
                                          mean_budget, 계약기간, 결과)

k_means_data$결과 <- ifelse(k_means_data$결과 != "success", "non-success", k_means_data$결과)
  
# 데이터 스케일링
training_data <- scale(k_means_data[-6])
summary(training_data)

# 모델 빌딩
pg_kmeans = kmeans(training_data, centers = 2, iter.max = 10000)
pg_kmeans$centers

# 결과 확인
k_means_data$cluster<-as.factor(pg_kmeans$cluster)
qplot(기간,계약기간,colour=cluster,data=k_means_data)

# 결과 변수와 비교해서 확인해보기
table(k_means_data$결과, k_means_data$cluster)

### cluster 갯수 정하기
nc <- NbClust(training_data, min.nc=2, max.nc=15, method="kmeans")
par(mfrow=c(1,1))
barplot(table(nc$Best.n[1,]),
        xlab="Numer of Clusters", ylab="Number of Criteria",
        main="Number of Clusters Chosen")


wssplot <- function(data, nc=15, seed=1234){
  wss <- (nrow(data)-1)*sum(apply(data,2,var))
  for (i in 2:nc){
    set.seed(seed)
    wss[i] <- sum(kmeans(data, centers=i)$withinss)}
  plot(1:nc, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares")}

wssplot(training_data)




## decision tree
library(caret)
library(rpart)
dt <- pgfinal %>% filter(결과 != "drop")
dt <- dt %>% select(산업군, 기간, 파일, 문의년도, 문의월, 분기, 
                       positive_count, negative_count, 계약기간, mean_budget, Bid, 결과)
dt$산업군 <- as.factor(dt$산업군)
dt$기간 <- ifelse(dt$기간 < 0, 0, dt$기간)
dt$파일 <- as.factor(dt$파일)
dt$분기 <- as.factor(dt$분기)
dt$Bid <- as.factor(dt$Bid)
dt$결과 <- as.factor(dt$결과)

rpartmod<-rpart(결과~. , data=dt, method="class")
plot(rpartmod)
text(rpartmod)

plotcp(rpartmod)

ptree<-prune(rpartmod, cp= rpartmod$cptable[which.min(rpartmod$cptable[,"xerror"]),"CP"])
plot(ptree)
text(ptree)


org <- read.xlsx("/Users/jeongseohyeong/Desktop/Summer 18/Bigdata Project/saleslist(original).xlsx")

### 기간 data cleansing
pgnn <- pgnn %>% filter(!is.na(결과))

boxplot(pgnn$기간)
summary(pgnn$기간)

pgfinal %>% ggplot(aes(y=기간)) + geom_boxplot()

test <- pgnn %>% filter(기간 > 50)
test <- pgfinal %>% filter(기간 > 40)

pgfinal <- pgfinal %>% filter(기간 <= 50)
pgfinal %>% ggplot(aes(y=기간)) + geom_boxplot()
summary(pgfinal$기간) # 50이상 아웃라이어로 생각해서 삭제하고 median 12.00

pgfinal$기간 <- ifelse(pgfinal$기간 < 0, 12, pgfinal$기간)
pgfinal %>% ggplot(aes(y=기간)) + geom_boxplot()
summary(pgfinal$기간)


## mean_budget
pgfinal %>% ggplot(aes(y=mean_budget)) + geom_boxplot()
summary(pgnn$mean_budget)

test <- pgnn %>% filter(mean_budget > 20)

pgfinal <- pgfinal %>% filter(mean_budget <= 20) 
pgfinal %>% ggplot(aes(y=mean_budget)) + geom_boxplot()

pgfinal %>% filter(결과 != "drop") %>% ggplot(aes(y=mean_budget)) + geom_boxplot()

pgfinal$산업군 <- as.factor(pgfinal$산업군)
pgfinal$파일 <- as.factor(pgfinal$파일)
pgfinal$문의년도 <- as.factor(pgfinal$문의년도)
pgfinal$문의월 <- as.factor(pgfinal$문의월)
pgfinal$분기 <- as.factor(pgfinal$분기)
pgfinal$Bid <- as.factor(pgfinal$Bid)
pgfinal$결과 <- as.factor(pgfinal$결과)

pgfinal <- pgfinal[,-1]
  
write.xlsx(pgfinal, "/Users/jeongseohyeong/Desktop/pgfinal.xlsx")  

org$Bid <- as.factor(org$Bid)
summary(org$Bid)



### 3) cramer's v heatmap between categorical variable

library(data.table) # data mgmt
library(gtools) # combination

cramer <- pgfinal %>% select(산업군, 파일, 문의년도, 문의월, 분기, Bid, 결과)
#cramer$파일 <- as.factor(cramer$파일)
#cramer$분기 <- as.factor(cramer$분기)

cat_var <- colnames(cramer)

# Function to compute Cramer's V
cv.test = function(x,y) {
  CV = sqrt(chisq.test(x, y, correct=FALSE)$statistic /
              (length(x)[1] * (min(length(unique(x))[1],length(unique(y))[1]) - 1)))
  return(as.numeric(CV))
}

# Apply the function to the combination of categorical variable
v_cramer_all <- function(cat_var, df){
  cat_var_grid <- data.table(combinations(n = length(cat_var), r = 2, v = cat_var, repeats.allowed = FALSE))
  
  do.call(rbind,
          apply(cat_var_grid, 1, function(x){
            tmp <- as.character(x)
            vec1 <- unlist(df[tmp[1]])
            vec2 <- unlist(df[tmp[2]])
            
            data.table(
              variable_x = tmp[1],
              variable_y = tmp[2],
              chi2 = chisq.test(x = vec1, vec2, correct=FALSE)$p.value,
              v_cramer = cv.test(x = vec1, y = vec2)
            )
          }))
  
}

results <- v_cramer_all(cat_var = cat_var, df = cramer)


### 4) correlation between numerical variables

#NA 없애고 해야

# Heatmap vizualisation with ggplot2  -------------------------------------

g <- ggplot(results, aes(variable_x, variable_y)) +
  geom_tile(aes(fill = v_cramer), colour = "black") +
  theme(axis.text.x=element_text(angle=45, hjust=1)) +
  scale_fill_gradient(low = "white", high = "steelblue") +
  theme_set(theme_gray(base_family = 'NanumGothic')) +
  xlab(NULL) + ylab(NULL) + theme(axis.text.x=element_text(angle = -90, hjust = 0)) +
  ggtitle("Cramer's V heatmap")

## Cramér's V varies from 0 (corresponding to no association between the variables) 
## to 1 (complete association) and can reach 1 only when the two variables are 
## equal to each other.

library(corrplot)
M <- cor(pgfinal[, c(2, 7, 8, 9, 10)])
corrplot(M, method="circle")


  