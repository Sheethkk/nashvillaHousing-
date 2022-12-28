-- cleaning Data 
use Portfolio;

select * from NashvilleHousing;

-- Standardised Date (clean date format)
select  SaleDate from NashvilleHousing;

select SaleDate, convert(Date,saleDate)
from NashvilleHousing;

--Updating the cleaned date in Table 
update NashvilleHousing
set SaleDate=convert(Date,saleDate)

alter table NashvilleHousing
add saleDateConverted Date;

update NashvilleHousing
set saleDateConverted=convert(Date,saleDate)

select saleDATEcONVERTED FROM NashvilleHousing;

select * from NashvilleHousing;


-- Populate property Address data

select* from NashvilleHousing
--WHERE PropertyAddress IS NULL;
ORDER BY ParcelID;


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.propertyaddress,b.propertyaddress)
from NashvilleHousing a
jOIN NashvilleHousing b
on a.ParcelID=b.ParcelID 
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress= isnull(a.propertyaddress,b.propertyaddress)
from NashvilleHousing a
jOIN NashvilleHousing b
on a.ParcelID=b.ParcelID 
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out address into individual columns(address,city,state)

select propertyaddress from NashvilleHousing;

select 
SUBSTRING(propertyaddress,1,charindex(',',Propertyaddress)-1) as address,
SUBSTRING(propertyaddress,charindex(',',Propertyaddress)+1,LEN(propertyaddress))as Address

from NashvilleHousing;

-- Creating Column so that data can be updated for the propertyadress making new column and updating  
alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress=SUBSTRING(propertyaddress,1,charindex(',',Propertyaddress)-1)

alter table NashvilleHousing
add PropertySplitcity nvarchar(255);

update NashvilleHousing
set PropertySplitcity=SUBSTRING(propertyaddress,charindex(',',Propertyaddress)+1,LEN(propertyaddress));

select * from NashvilleHousing;



--------------------------------------------------------Second way of Spliting the Data-------------------------------------------
-- cleaning up owneradress 
-- (Parsename) is used for period example(01.01.2022) which than converted 
-- in this we used , so converting (,) into (.) so that it can be used for separating the data 

select
PARSENAME(replace(ownerAddress,',','.'),3),
PARSENAME(replace(ownerAddress,',','.'),2),
PARSENAME(replace(ownerAddress,',','.'),1)
from NashvilleHousing;

-- Create new column and insert the split data 

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress=PARSENAME(replace(ownerAddress,',','.'),3);

alter table NashvilleHousing
add OwnerSplitcity nvarchar(255);

update NashvilleHousing
set OwnerSplitcity=PARSENAME(replace(ownerAddress,',','.'),2);

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState=PARSENAME(replace(ownerAddress,',','.'),1);

select * from NashvilleHousing;


-- change Y and N and No in 'sold as vacant" field

select distinct(soldasvacant),count(soldasvacant)
from NashvilleHousing
group by soldasvacant
order by 2;


--- changing the 'N' to 'No' and 'Y' to 'Yes'--

select soldasvacant 
, case when soldasvacant ='Y' Then 'Yes'
		when soldasvacant ='N' Then 'No'
		else soldasvacant
		End
from NashvilleHousing

-- updating the Table --
update NashvilleHousing
set SoldAsVacant=case when soldasvacant ='Y' Then 'Yes'
		when soldasvacant ='N' Then 'No'
		else soldasvacant
		End

-- checking update--
select distinct(soldasvacant),count(soldasvacant)
from NashvilleHousing
group by soldasvacant
order by 2;

-- Remove the dulpicates --
--using CTE
with RownumCTE as(
select *, 
	row_number() over(
	partition by ParcelID,
			PropertyAddress,
			salePrice,
			LegalReference
			order by UniqueId
			) row_num
from nashvillehousing
)
select * from RownumCTE
where Row_num>1


-- deleting the row --
with RownumCTE as(
select *, 
	row_number() over(
	partition by ParcelID,
			PropertyAddress,
			salePrice,
			LegalReference
			order by UniqueId
			) row_num
from nashvillehousing
)
Delete from RownumCTE
where Row_num>1


-- Delete unused columns 
select * from NashvilleHousing;

alter table  NashvilleHousing
drop column OwnerAddress,TaxDistrict,PropertyAddress;

alter table  NashvilleHousing
drop column saledate;