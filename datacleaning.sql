/*

Clearing data in sql queries

*/

select * from [Data Cleaning]..NashveilHousing

----- standard date format

select SaleDate, Convert(Date,SaleDate)
from [Data Cleaning]..NashveilHousing



Alter table NashveilHousing
add SalesDate2 Date;

Update NashveilHousing
SET SalesDate2 = Convert(Date,SaleDate)

select SalesDate2 from [Data Cleaning]..NashveilHousing

------------------------------------------------------------------------------

------Populate property Address data

select PropertyAddress
from [Data Cleaning]..NashveilHousing


select a.ParcelID,a.PropertyAddress,b.PropertyAddress, ISNULL(b.PropertyAddress,a.PropertyAddress)
from [Data Cleaning]..NashveilHousing a
join [Data Cleaning]..NashveilHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where b.PropertyAddress is null

update b
set PropertyAddress = ISNULL(b.PropertyAddress,a.PropertyAddress)
from [Data Cleaning]..NashveilHousing a
join [Data Cleaning]..NashveilHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where b.PropertyAddress is null

----------------------------------------------------------------------------------

-----Breaking out Address into Individual Columns (Address,City, State)

--property address
select PropertyAddress
from [Data Cleaning]..NashveilHousing

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as address
from [Data Cleaning]..NashveilHousing

Alter table [Data Cleaning]..NashveilHousing
add PropertySplitAdress nvarchar(255);

Update [Data Cleaning]..NashveilHousing
SET PropertySplitAdress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter table [Data Cleaning]..NashveilHousing
add PropertySplitCity nvarchar(255);

Update [Data Cleaning]..NashveilHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select * from [Data Cleaning]..NashveilHousing


--owner address

select
PARSENAME(replace(OwnerAddress,',','.'),1) --difference between parsename andsubstring is that parsename replace character with '.' also do backtracing 
from [Data Cleaning]..NashveilHousing

Alter table [Data Cleaning]..NashveilHousing
add OwnerSplitAddress nvarchar(255);

Update [Data Cleaning]..NashveilHousing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

Alter table [Data Cleaning]..NashveilHousing
add OwnerSplitCity nvarchar(255);

Update [Data Cleaning]..NashveilHousing
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

Alter table [Data Cleaning]..NashveilHousing
add OwnerSplitState nvarchar(255);

Update [Data Cleaning]..NashveilHousing
SET OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)


select * from [Data Cleaning]..NashveilHousing

---------------------------------------------------------------------------


-----change Y and N to yes and no "Sold as vacant" field

select distinct(SoldAsVacant),count(SoldAsVacant)
 from [Data Cleaning]..NashveilHousing
 group by SoldAsVacant

 select SoldAsVacant,
 case when SoldAsVacant = 'Y' THEN 'YES'
	  when SoldAsVacant = 'N' THEN 'NO'
	  else SoldAsVacant
	  end
	
  from [Data Cleaning]..NashveilHousing

  update [Data Cleaning]..NashveilHousing
  set SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'YES'
	  when SoldAsVacant = 'N' THEN 'NO'
	  else SoldAsVacant
	  end

------------------------------------------------------------------------------

--Remove Duplicates
with rownumcte as(
select *,
 ROW_NUMBER() over (
 partition by ParcelID,
			  PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  order by
			  UniqueID
					) row_num
from [Data Cleaning]..NashveilHousing
)
select * from rownumcte
where row_num>1
order by ParcelID

WITH rownumcte as(
select *,
 ROW_NUMBER() over (
 partition by ParcelID,
			  PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  order by
			  UniqueID
					) row_num
from [Data Cleaning]..NashveilHousing
)

delete from rownumcte where row_num>1

------------------------------------------------------------------------------


-----delete unusual columns


select * from [Data Cleaning]..NashveilHousing

alter table [Data Cleaning]..NashveilHousing
drop column PropertyAddress,SaleDate,OwnerAddress,TaxDistrict

