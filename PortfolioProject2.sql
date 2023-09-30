/*

Cleaning Data in SQL Queries

*/


select *
from PortfolioProject..NashvilleHousing





-- Standardize Date Format

select SaleDateConverted, CONVERT(Date, SaleDate) 
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date, SaleDate) 

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(Date, SaleDate)





-- Populate Property Address data

select *
from PortfolioProject..NashvilleHousing
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null





-- Breaking out Address into Individual Columns (Address, State, City)

select PropertyAddress
from PortfolioProject..NashvilleHousing

select 
substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address,
substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) 

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))  

select * 
from PortfolioProject..NashvilleHousing





select OwnerAddress
from PortfolioProject..NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3), 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2), 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from PortfolioProject..NashvilleHousing


ALTER TABLE NashVilleHousing
Add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashVilleHousing
Add OwnerSplitCity nvarchar(255)

update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashVilleHousing
Add OwnerSplitState nvarchar(255)

update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)





-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant 
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
from PortfolioProject..NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END 





-- Remove Duplicates

WITH RowNumCTE as(
select *,
	ROW_NUMBER() OVER(
	PARTITION  BY ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY
					UniqueID
					) row_num

from PortfolioProject..NashvilleHousing
)


delete
from RowNumCTE
where row_num > 1





-- Delete Unused Columns 

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate

Select *
From PortfolioProject..NashvilleHousing