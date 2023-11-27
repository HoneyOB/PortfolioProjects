/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProject_1..NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject_1..NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)



----------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
From PortfolioProject_1..NashvilleHousing
--Where PropertyAddress  is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject_1..NashvilleHousing a
JOIN PortfolioProject_1..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID] 
Where a.PropertyAddress is null

Update  a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject_1..NashvilleHousing a
JOIN PortfolioProject_1..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID] 
Where a.PropertyAddress is null



----------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject_1..NashvilleHousing
--Where PropertyAddress  is null
--Order by ParcelID

Select 
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From PortfolioProject_1..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



Select OwnerAddress
From PortfolioProject_1..NashvilleHousing

Select
PARSENAME (REPLACE (OwnerAddress, ',', '.'), 3) AS Address
, PARSENAME (REPLACE (OwnerAddress, ',', '.'), 2) AS City
, PARSENAME (REPLACE (OwnerAddress, ',', '.'), 1) AS State
From PortfolioProject_1..NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE (OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE (OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE (OwnerAddress, ',', '.'), 1)



----------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject_1..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject_1..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END



-----------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE As (
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order By 
						UniqueID
						) row_num
From PortfolioProject_1..NashvilleHousing
--Order By ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order By PropertyAddress



------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
From PortfolioProject_1..NashvilleHousing


ALTER TABLE PortfolioProject_1..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject_1..NashvilleHousing
DROP COLUMN SaleDate




--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Reorganize Table
  
CREATE TABLE NashvilleHousingRecords(
	UniqueID INT,
	ParcelID NVARCHAR(50),
	LegalReference NVARCHAR(50),
	PropertyAddress NVARCHAR(50),
	PropertyCity NVARCHAR(50),
	OwnerName NVARCHAR(50),
	OwnerAddress NVARCHAR(50),
	OwnerCity NVARCHAR(50),
	OwnerState NVARCHAR(50),
	LandUse NVARCHAR(50),
	Acreage FLOAT,
	YearBuilt FLOAT,
	Bedrooms FLOAT,
	FullBath FLOAT,
	HalfBath FLOAT,
	LandValue FLOAT,
	BuildingValue FLOAT,
	TotalValue FLOAT,
	SalePrice FLOAT,
	SoldAsVacant NVARCHAR(50)
	)

Alter Table NashvilleHousingRecords
Alter Column OwnerName NVARCHAR(255)

INSERT INTO PortfolioProject_1..NashvilleHousingRecords(
UniqueID, ParcelID, LegalReference, PropertyAddress
, PropertyCity, OwnerName, OwnerAddress, OwnerCity
, OwnerState, LandUse, Acreage, YearBuilt, Bedrooms
, FullBath, HalfBath, LandValue, BuildingValue,TotalValue
, SalePrice, SoldAsVacant)
Select 
UniqueID, ParcelID, LegalReference, PropertySplitAddress
, PropertySplitCity, OwnerName, OwnerSplitAddress, OwnerSplitCity
, OwnerSplitState, LandUse, Acreage, YearBuilt, Bedrooms
, FullBath, HalfBath, LandValue, BuildingValue,TotalValue
, SalePrice, SoldAsVacant
From PortfolioProject_1..NashvilleHousing


Select *
From PortfolioProject_1..NashvilleHousingRecords
Order By YearBuilt 

Drop Table NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------

