--Step 1: Manually set the query's start time.
DECLARE @StartTime AS DATETIME
SET @StartTime = '2024-09-24 07:00:00'

--Step 2: Manually set the query's end time.
DECLARE @EndTime AS DATETIME
SET @EndTime = '2024-09-24 15:00:00'

--Step 3: Manually set the machine name
DECLARE @MachineName AS NCHAR(10)
SET @MachineName = 'CNC4'

--Don't change any code below
-----------------------------

--Calculate and add Duration to the raw data
;WITH DurationTable AS
(
SELECT [PARTCOUNT] AS PartCount,
       @MachineName AS MachineName,
	   [TIME] AS SampleTime,
	   [MACHINESTATE] AS MachineState,
	   [ACTIVEFILE] AS ActiveFile,
	   [FLEX] AS Flex,
	   RANK() OVER (ORDER BY [TIME]) AS IndexColumn,
	   DATEDIFF(second, [TIME],LEAD([TIME], 1) OVER(ORDER BY [TIME] ASC)) AS DurationSec
FROM CNC4
WHERE [TIME] >= @StartTime  AND [TIME] <= @EndTime
),

--Group data by PartCount
PartTable AS (
SELECT [PartCount],
       MAX([MachineName]) AS MachineName,
	   MAX([Flex]) AS Flex,
	   MIN([SampleTime]) AS PartStartTime,
	   (SELECT MIN([SampleTime]) FROM DurationTable InnerQuery WHERE InnerQuery.[PartCount] > OuterQuery.[PartCount]) AS PartEndTime,
	   SUM([DurationSec])/60.0 AS GrossCycleTimeMin,
	   (SELECT SUM([DurationSec])/60.0 FROM DurationTable InnerQuery2 WHERE InnerQuery2.[MACHINESTATE] = 'ACTIVE' AND InnerQuery2.[PartCount] = OuterQuery.[PartCount]) AS NetCycleTimeMin,
	   (SELECT MAX([ACTIVEFILE]) FROM DurationTable InnerQuery4 WHERE InnerQuery4.[SampleTime] IN
			(SELECT MAX([SampleTime]) FROM DurationTable InnerQuery3 WHERE InnerQuery3.[MACHINESTATE] = 'ACTIVE' AND InnerQuery3.[PartCount] = OuterQuery.[PartCount])) AS LastActiveFile
FROM DurationTable OuterQuery
GROUP BY [PartCount]
)

--Calculate NetCycleTimePct and show data
SELECT [PartCount], 
       [MachineName],  
	   [LastActiveFile], 
	   [PartStartTime], 
	   [PartEndTime], 
	   [GrossCycleTimeMin], 
	   [NetCycleTimeMin], FORMAT(([NetCycleTimeMin]/[GrossCycleTimeMin]), 'P') AS NetCycleTimePct, 
	   [Flex]
FROM PartTable
ORDER BY [PartCount] ASC
