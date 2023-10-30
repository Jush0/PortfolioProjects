select *
From ProjectPortfolio..NashvilleHousing

-- Standardize Date Format

select SaledateConverted, CONVERT(Date, Saledate)
From ProjectPortfolio..NashvilleHousing

Update projectportfolio..NashvilleHousing
SET Saledate = Convert(Date,Saledate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update projectportfolio..NashvilleHousing
SET SaleDateConverted = Convert(Date,saledate)

-------------------------------------------------------------------------------------------------------------

-- Populate Property Address date

select *
From ProjectPortfolio..NashvilleHousing
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From ProjectPortfolio..NashvilleHousing a
join ProjectPortfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From ProjectPortfolio..NashvilleHousing a
join ProjectPortfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
From ProjectPortfolio..NashvilleHousing


Select
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From ProjectPortfolio..NashvilleHousing

Alter Table Nashvillehousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table Nashvillehousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select * 

From ProjectPortfolio.dbo.NashvilleHousing




Select OwnerAddress
From ProjectPortfolio.dbo.NashvilleHousing


Select
PARSENAME(Replace(Owneraddress, ',', '.') ,3)
,PARSENAME(Replace(Owneraddress, ',', '.') ,2)
,PARSENAME(Replace(Owneraddress, ',', '.') ,1)
From ProjectPortfolio.dbo.NashvilleHousing

Alter Table Nashvillehousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(Owneraddress, ',', '.') ,3)

Alter Table Nashvillehousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(Owneraddress, ',', '.') ,2)

Alter Table Nashvillehousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(Owneraddress, ',', '.') ,1)

Select * 

From ProjectPortfolio.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From ProjectPortfolio.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		END
From ProjectPortfolio.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		END




------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE As(
Select *,
ROW_Number() OVER (
PartITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			Order By
				UniqueID
				) row_num


From ProjectPortfolio.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress





Select * 
From ProjectPortfolio.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select * 
From ProjectPortfolio.dbo.NashvilleHousing

Alter table ProjectPortfolio.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter table ProjectPortfolio.dbo.NashvilleHousing
Drop Column SaleDate