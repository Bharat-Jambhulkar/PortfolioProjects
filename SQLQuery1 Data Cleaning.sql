/* 

CLEANING DATA IN SQL QUERIES

*/

SELECT *
FROM PortfolioProject..NashvilleHousing ;

------------------------------------------------------------------------------------

-- STANDARDIZED DATE FORMAT
-- THERE IS NO PROBLEM IN THIS FILE 


Select SaleDate, CONVERT(DATE,SaleDate)
FROM PortfolioProject..NashvilleHousing ;
	
ALTER TABLE NashvilleHousing --ADDING NEW COLUMN 
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing 
SET SaleDateConverted = CONVERT(DATE,SaleDate) 


--------------------------------------------------------------------------------------


-- POPULATE PROPERTY ADDRESS DATA 

-- PERFORMING THIS TASK NEED OBSERVATION OF DATA, WE HAVE FOUND THAT WHERE PARCELID IS SAME WE HAVE SAME PROPERTYADDRESS 

SELECT *
FROM PortfolioProject..NashvilleHousing 
-- Where PropertyAddress is null
ORDER BY ParcelID;


--USE SELF JOIN

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]  -- HERE WE HAVE PERFORMED SELF JOIN AND SORTED THOSE ROWS WHICH HAS SAME PARCELID BUT THE ROWS ARE DIFFRENT 
	--THIS SHOWS THAT HAVING SAME PARCELID INDICATES HAVING SAME PROPERTY ADDRESS
WHERE a.PropertyAddress is null -- SO THIS CAN BE USED TO FILL THE NULL VALUES OF PROPERTYADDRESS 


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID] 
WHERE a.PropertyAddress IS NULL 

UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress) --FILING UP THE NULL COLUMNS 
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID] 
WHERE a.PropertyAddress IS NULL  



-----------------------------------------------------------------------------------

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing -- DELIMINATOR IS SOMETHING THAT SEPARATES VALUES OR COLUMNS 

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,  -- CHARINDEX(',',PropertyAddress) THIS SHOWS THE INDEX OF COMMA SYMBOL
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing; -- WHAT WE HAVE DONE IS CREATED A SUBSTRING OF ADDRESS WHICH IS SENTENCE BEFORE COMMA (AGAIN THIS REQUIRES OBSERVATION OF DATA) 



ALTER TABLE NashvilleHousing --ADDING NEW COLUMN NAMED PropertySplitAddress
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 


ALTER TABLE NashvilleHousing --ADDING NEW COLUMN NAMED PropertySplitCity
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM PortfolioProject..NashvilleHousing -- RESULT  


-- SPLITING OWNER'S ADDRESS BY USING PARSENAME FUNCTION 

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing;  

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3), -- OARSNAME WORKS IN BACKWORD DIRECTION AND SEARCH FOR PERIOD '.'
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing;	-- THIS CAN BE USE AS ALTERNATIVE TO SUBSTRING 	


ALTER TABLE NashvilleHousing --ADDING NEW COLUMN NAMED OwnerSplitAddress
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing 
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousing --ADDING NEW COLUMN NAMED OwnerSplitCity
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE NashvilleHousing --ADDING NEW COLUMN NAMED OwnerSplitState
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing 
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress,',','.'),1)


SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM PortfolioProject..NashvilleHousing; -- RESULT  


-----------------------------------------------------------------------------------

-- REMOVE DUPLICATES 

SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 UniqueID
	) row_num
FROM NashvilleHousing
ORDER BY ParcelID;

-- USING CTE
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 UniqueID
	) row_num
FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num>1
ORDER BY PropertyAddress;



WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 UniqueID
	) row_num
FROM NashvilleHousing
)
DELETE 
FROM RowNumCTE
FROM RowNumCTE
WHERE row_num > 1; -- REMOVED ALL DUPLICATES 


-----------------------------------------------------------------------------------

-- REMOVING UNUSED COLUMNS 

SELECT * 
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate; 

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate; 