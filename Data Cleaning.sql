-- Cleaning Data Portfolio Project

select *
from PorfolioProject.dbo.NashvilleHousing

-- Edit Date format

select SaleDate
from PorfolioProject.dbo.NashvilleHousing

update NashvilleHousing
Set SaleDate = CONVERT(date,SaleDate)

------------------ new column with updated date

Alter table NashvilleHousing
add SaleDateUpdated date;

update NashvilleHousing
Set SaleDateUpdated = Convert(date,SaleDate)


-------------------------------------------------------------------

-- Populating Property Address Data to fix Nulls

Select *
From PorfolioProject..NashvilleHousing
order by ParcelID
------------------
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
From PorfolioProject..NashvilleHousing a
join PorfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null
-------------------
update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
From PorfolioProject..NashvilleHousing a
join PorfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

-------------------------------------------------------------------

-- Getting Adress into individual columns (adress, city, state)

Select PropertyAddress
from PorfolioProject..NashvilleHousing


select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1 , LEN(PropertyAddress)) as City
from PorfolioProject..NashvilleHousing

Alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);
Alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);


update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1 )
update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1 , LEN(PropertyAddress))

----------------------------------------------------------------------

-- Working on OwnerAddress column

Select OwnerAddress
from PorfolioProject..NashvilleHousing
----------------------------
select
parsename(Replace(OwnerAddress, ',', '.') ,3)
,parsename(Replace(OwnerAddress, ',', '.') ,2)
,parsename(Replace(OwnerAddress, ',', '.') ,1)
from PorfolioProject..NashvilleHousing

----------------------------- 
Alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);
Alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);
Alter table NashvilleHousing
add OwnerSplitstate Nvarchar(255);

update NashvilleHousing
Set OwnerSplitAddress = parsename(Replace(OwnerAddress, ',', '.') ,3)
update NashvilleHousing
Set OwnerSplitCity = parsename(Replace(OwnerAddress, ',', '.') ,2)
update NashvilleHousing
Set OwnerSplitstate = parsename(Replace(OwnerAddress, ',', '.') ,1)
------- 
Select *
from PorfolioProject

---------------------------------------------------------------------
-- changing y and n to yes and no in SoldAsVacant

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PorfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant
, Case When SoldAsVacant = 'Y' then 'Yes'
       When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End
from PorfolioProject..NashvilleHousing


update NashvilleHousing
set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
       When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End

-----------------------------------------------------------
-- Remove Duplicates

with rownumCTE as(
Select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num
from PorfolioProject..NashvilleHousing
)


Delete
from rownumCTE
where row_num > 1
order by PropertyAddress




--Select *
--from rownumCTE
--where row_num > 1
--order by PropertyAddress


From PorfolioProject..NashvilleHousing

------------------------------------------------------
-- Delete Unused Columns


Select *
From PorfolioProject..NashvilleHousing

Alter table PorfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

