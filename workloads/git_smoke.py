from pyspark.sql import SparkSession

spark = SparkSession.builder.getOrCreate()
records = [(i, f"record-{i}") for i in range(1, 11)]
df = spark.createDataFrame(records, ["id", "name"])
df.show(truncate=False)
