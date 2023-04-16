select *
from sql..NashvilleHousing

--chnaging date format
select SaleDateConverted, CONVERT(date, SaleDate) 
from sql..NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted Date;

update sql..NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate) 


--populating PropertyAddress
select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress,b.PropertyAddress)
from sql..NashvilleHousing a
join sql..NashvilleHousing b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress =  ISNULL(a.propertyAddress,b.PropertyAddress)
from sql..NashvilleHousing a
join sql..NashvilleHousing b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--spliting property Address
select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1) as PropertysplitAaddress
,SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as PropertsplitCity
from sql..NashvilleHousing

alter table sql..NashvilleHousing
add PropertySplitAddress nvarchar(200)

update sql..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1)

alter table sql..NashvilleHousing
add PropertySplitCity nvarchar(200)

update sql..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--spliting OwnerAddress
select OwnerAddress
from  sql..NashvilleHousing

select 
PARSENAME (replace(OwnerAddress,',','.'),3)
,PARSENAME (replace(OwnerAddress,',','.'),2)
,PARSENAME (replace(OwnerAddress,',','.'),1)
from sql..NashvilleHousing


alter table sql..NashvilleHousing
add OwnerSplitAddress nvarchar(200)

update sql..NashvilleHousing
set OwnerSplitAddress = PARSENAME (replace(OwnerAddress,',','.'),3)



alter table sql..NashvilleHousing
add OwnerSplitCity nvarchar(200)

update sql..NashvilleHousing
set OwnerSplitCity = PARSENAME (replace(OwnerAddress,',','.'),2)



alter table sql..NashvilleHousing
add OwnerSplitState nvarchar(200)

update sql..NashvilleHousing
set OwnerSplitState = PARSENAME (replace(OwnerAddress,',','.'),1)

select *
from sql..NashvilleHousing

--changing yes and no in soldas vacant
select distinct(SoldAsVacant), COUNT(soldasvacant)
from sql..NashvilleHousing
group by SoldAsVacant

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from sql..NashvilleHousing

update sql..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

--Removing Duplicates
with ctereownum as(
select *,
ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 order by
				 uniqueid
				  )rownum
from sql..NashvilleHousing)

select *
from ctereownum
where rownum>1
order by 1

--delete unused columns
select *
from sql..NashvilleHousing

alter table sql..NashvilleHousing
drop column saleDate, PropertyAddress, OwnerAddress, TaxDistrict