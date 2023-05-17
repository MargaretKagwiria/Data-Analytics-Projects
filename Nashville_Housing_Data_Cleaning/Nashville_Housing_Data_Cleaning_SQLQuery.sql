SELECT *
FROM Nashville_Housing_Project..Nashville_Housing

-- Standardize the sale date format
SELECT SaleDate,
	CONVERT(Date,SaleDate)
FROM Nashville_Housing_Project..Nashville_Housing

UPDATE Nashville_Housing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE Nashville_Housing
ADD SaleDateConverted Date;

UPDATE Nashville_Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)


-- Populate the property address data
SELECT *
FROM Nashville_Housing_Project..Nashville_Housing
WHERE PropertyAddress IS NULL
-- There are some null values in the property address column but if you observe the data, the parcelID data is directly linked to the property 
-- address column. So we will use the parcelID column to populate the property address column by using self join method
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville_Housing_Project..Nashville_Housing AS a
JOIN Nashville_Housing_Project..Nashville_Housing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville_Housing_Project..Nashville_Housing AS a
JOIN Nashville_Housing_Project..Nashville_Housing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress IS NULL


-- Separating the Property address into individual columns (Address, City)
SELECT PropertyAddress
FROM Nashville_Housing_Project..Nashville_Housing

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM Nashville_Housing_Project..Nashville_Housing

ALTER TABLE Nashville_Housing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Nashville_Housing
ADD PropertySplitCity NVARCHAR(255);

UPDATE Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-- Separating the Owner Address (Address, City, State) using PARSENAME instead of SUBSTRING
SELECT
	PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Nashville_Housing_Project..Nashville_Housing

ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Nashville_Housing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Nashville_Housing
ADD OwnerSplitState NVARCHAR(255);

UPDATE Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


-- Change Y and N in SoldAsVacant to Yes and No
SELECT
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM Nashville_Housing_Project..Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM Nashville_Housing_Project..Nashville_Housing

UPDATE Nashville_Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END


-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
		 PropertyAddress,
		 SalePrice,
		 LegalReference
		 ORDER BY
			UniqueID
				) row_num
FROM Nashville_Housing_Project..Nashville_Housing)
DELETE
FROM RowNumCTE
WHERE row_num >1


-- Delete unused columns
SELECT *
FROM Nashville_Housing_Project..Nashville_Housing

ALTER TABLE Nashville_Housing_Project..Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

