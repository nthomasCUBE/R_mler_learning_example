# modified default example from mler package

library(mler)
library(mlbench)
library(ranger)
library(cmaes)

data(BostonHousing, package = "mlbench")
boxplot(BostonHousing)

regr.task = makeRegrTask(data = BostonHousing, target = "medv")
regr.task

set.seed(1234)

ps_ksvm = makeParamSet(
  makeNumericParam("sigma", lower = -12, upper = 12, trafo = function(x) 2^x)
)

ps_rf = makeParamSet(
  makeIntegerParam("num.trees", lower = 1L, upper = 200L)
)

rdesc = makeResampleDesc("CV", iters = 5L)

meas = rmse

ctrl = makeTuneControlCMAES(budget = 100L)

tuned.ksvm = makeTuneWrapper(learner = "regr.ksvm", resampling = rdesc, measures = meas,
  par.set = ps_ksvm, control = ctrl, show.info = FALSE)
tuned.rf = makeTuneWrapper(learner = "regr.ranger", resampling = rdesc, measures = meas,
  par.set = ps_rf, control = ctrl, show.info = FALSE)

lrns = list(makeLearner("regr.lm"), tuned.ksvm, tuned.rf)

bmr = benchmark(learners = lrns, tasks = regr.task, resamplings = rdesc, measures = rmse, 
  show.info = FALSE)

getBMRAggrPerformances(bmr)

plotBMRBoxplots(bmr)


