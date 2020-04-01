import Foundation
import CreateML

let data = try MLDataTable(contentsOf: URL(fileURLWithPath: "/path/to/ClassifierOutput.csv"))
let (trainingData, testingData) = data.randomSplit(by: 0.8, seed: 5)

let noMoPromoClassifier = try MLTextClassifier(trainingData: trainingData, textColumn: "Text", labelColumn: "isAd")

let trainingAccuracy = (1 - noMoPromoClassifier.trainingMetrics.classificationError) * 100
let validationAccuracy = (1 - noMoPromoClassifier.trainingMetrics.classificationError) * 100

let evaluationMetrics = noMoPromoClassifier.evaluation(on: testingData, textColumn: "Text", labelColumn: "isAd")
let evaluationAccuracy = (1 - evaluationMetrics.classificationError) * 100

let metadata = MLModelMetadata(author: "JacobCXDev", shortDescription: "A model trained to classify whether an Instagram post caption is an advertisement or not.", license: "MIT", version: "1.0")
try noMoPromoClassifier.write(to: URL(fileURLWithPath: "/output/path/NoMoPromoClassifier.mlmodel"), metadata: metadata)
