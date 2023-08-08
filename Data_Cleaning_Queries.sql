/*
Cleaning Data using SQL Queries 
*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing




---- Standardising SaleDate
SELECT SaleDate
FROM PortfolioProject.dbo.NashvilleHousing

SELECT SalesDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SalesDateConverted = CONVERT(Date, SaleDate)




---- Irregularities among the PropertyAddress 
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
----WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL




---- Breaking out the Address Column (Address, City, State)
SELECT PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing

SELECT OwnerAddress
FROM NashvilleHousing

---- Up until now [for PropertyAddress] we have been using SUBSTRING,
---- Now [for OwnerAddress] lets try implementing PARSENAME.

SELECT 
PARSENAME(OwnerAddress, 1)
FROM NashvilleHousing --nothing will happen since, parsename is looking for '.'
---- therefore we first replace the ',' with a '.' for parsename to work.

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
from NashvilleHousing --yields the result in reverse, 
---- therefore

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)




---- Change Y and N to 'Yes' and 'No' in SoldAsVacant
select Distinct(SoldAsVacant)
from NashvilleHousing

select Distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant 
	 END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant 
						END




---- Deleting Duplicates  
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID) as row_num
FROM NashvilleHousing
ORDER BY ParcelID ---- when we're doing this it is actually challenging to find the duplicates [row_num] in a large number of values.
---- therefore we have to be able to run a WHERE Clause Where row_num > 2... For that we use CTE.

---- # 2  
WITH RowNumCTE as (
	SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY 
						UniqueID) as row_num
		FROM NashvilleHousing)
SELECT *  
FROM RowNumCTE 
WHERE row_num > 1
ORDER BY PropertyAddress

---- # 1
--WITH RowNumCTE as (
--	SELECT *,
--		ROW_NUMBER() OVER (
--		PARTITION BY ParcelID,
--					PropertyAddress,
--					SalePrice,
--					SaleDate,
--					LegalReference
--					ORDER BY 
--						UniqueID) as row_num
--		FROM NashvilleHousing)
--DELETE  
--FROM RowNumCTE 
--WHERE row_num > 1




---- Deleting Unused Columns
---- We Dont delete anything from the RAW Data, that is originally there, unless we're asked/told to.  
---- We can use this to remove the columns we added on purpose, but ended up not using them.
---- Here we are deleting the SaleDate, PropertyAddress, OwnerAddress, and TaxDistrict Columns, Just for Demonstration purposes.
---- And because we've separated the Addresses (Or hypothetically we were ASKED/TOLD to delete these columns).

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate




---- The whole point here is to CLEAN the data in order to make it MORE USABLE.
SELECT *
FROM NashvilleHousing