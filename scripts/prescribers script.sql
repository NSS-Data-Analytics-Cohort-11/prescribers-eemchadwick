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
 
 --3b. Which drug (generic_name) has the hightest total cost per day? Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.
 SELECT drug.generic_name, prescription.total_30_day_fill_count --SUM(prescription.total_drug_cost), 
 FROM drug
 INNER JOIN prescription
 ON drug.drug_name = prescription.drug_name
 GROUP BY drug.generic_name
 ORDER BY SUM(prescription.total_drug_cost) DESC
 LIMIT 30;
 --answer: 