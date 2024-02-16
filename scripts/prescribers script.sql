SELECT *
FROM prescriber;

SELECT*
from prescription;

SELECT *
from drug;

--1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT npi, SUM(total_claim_count) AS total_claims
FROM prescription
GROUP BY npi
ORDER BY SUM(prescription.total_claim_count) DESC
LIMIT 5;
--answer: NPI - 1881634483, total claims - 99707

--1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.
SELECT prescription.npi, SUM(prescription.total_claim_count) AS total_claims, prescriber.nppes_provider_first_name, prescriber.nppes_provider_last_org_name, prescriber.specialty_description
FROM prescription
INNER JOIN prescriber
ON prescription.npi = prescriber.npi
GROUP BY prescription.npi, prescriber.nppes_provider_first_name, prescriber.nppes_provider_last_org_name, prescriber.specialty_description
ORDER BY SUM(prescription.total_claim_count) DESC
LIMIT 5;
--answer: 1881634483	99707	"BRUCE"	"PENDLEY"	"Family Practice"

--2.a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT SUM(prescription.total_claim_count) AS total_claims, prescriber.specialty_description
FROM prescription
INNER JOIN prescriber
ON prescription.npi = prescriber.npi
GROUP BY prescriber.specialty_description
ORDER BY SUM(prescription.total_claim_count) DESC
LIMIT 5;
--answer: "Family Practice"

--2b. Which specialty had the most total number of claims for opioids?
SELECT prescriber.specialty_description, SUM(prescription.total_claim_count)
FROM prescription
INNER JOIN prescriber
ON prescription.npi = prescriber.npi
INNER JOIN drug
ON prescription.drug_name = drug.drug_name
WHERE opioid_drug_flag = 'Y' OR long_acting_opioid_drug_flag = 'Y'
GROUP BY prescriber.specialty_description 
ORDER BY SUM(prescription.total_claim_count) DESC 
LIMIT 10;
--answer:"Nurse Practitioner"

--2c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

--2d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

--3a. Which drug (generic_name) had the highest total drug cost?
 SELECT drug.generic_name, SUM(prescription.total_drug_cost)
 FROM drug
 INNER JOIN prescription
 ON drug.drug_name = prescription.drug_name
 GROUP BY drug.generic_name
 ORDER BY SUM(prescription.total_drug_cost) DESC
 LIMIT 30;
 --answer:"INSULIN GLARGINE,HUM.REC.ANLOG"
 
 --3b. Which drug (generic_name) has the highest total cost per day? Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.
 SELECT drug.generic_name, ROUND(SUM(prescription.total_drug_cost)/SUM(prescription.total_day_supply), 2) AS cost_per_day 
 FROM drug
 INNER JOIN prescription
 ON drug.drug_name = prescription.drug_name
 GROUP BY drug.generic_name
 ORDER BY SUM(prescription.total_drug_cost)/SUM(prescription.total_day_supply) DESC
 LIMIT 10;
 --answer: "C1 ESTERASE INHIBITOR"
 
 --4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. Hint: You may want to use a CASE expression for this.
SELECT drug_name, 
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
ELSE 'neither' END AS drug_type
FROM drug;
--answer: run query

--4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT MONEY(SUM(total_drug_cost)) AS total_drug_cost,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither' END AS drug_type
FROM drug
INNER JOIN prescription
ON drug.drug_name = prescription.drug_name
GROUP BY drug_type
ORDER BY total_drug_cost DESC;
--answer: opioids

--5.a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.
SELECT cbsa, cbsaname
FROM cbsa
WHERE cbsaname LIKE '%TN'
GROUP BY cbsa, cbsaname;
--answer: 6

--5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT cbsa, SUM(population.population) AS combined_population
FROM cbsa
INNER JOIN population
ON cbsa.fipscounty = population.fipscounty
GROUP BY cbsa
ORDER BY combined_population DESC;
--answer: largest population cbsa:"34980", population: 1830410
--smallest - cbsa "34100", population: 116352

--5c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT county, population, cbsa, state
FROM fips_county
FULL JOIN population
ON fips_county.fipscounty = population.fipscounty
FULL JOIN cbsa
ON population.fipscounty = cbsa.fipscounty
WHERE cbsa IS NULL
AND population IS NOT NULL
ORDER BY population DESC;
--answer: "SEVIER", 95523

--6. a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;
--answer: run query

--6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT drug_name, total_claim_count, opioid_drug_flag,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	ELSE 'not opioid' END AS drug_type
FROM prescription
INNER JOIN drug
USING (drug_name)
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC;


