select *
from sql_project.dbo.NashvilleHousing


--Converting SaleDate column from DateTime data type to just Date 

alter table NashvilleHousing
add SaleDateConverted date;

Update NashvilleHousing
set SaleDateConverted = convert(Date, SaleDate);

select SaleDateConverted
from sql_project.dbo.NashvilleHousing;

--Populating the property addresses of records where the column is left blank.
--Upon closer examination, we can see that there exist multiple instances of the same property address in the data set and the
--the parcel IDs corresopond to the property addresses where they are unique for any given address. So our approach is to look
--for dupliacte instances of the parcel ids for records where the property address is left blank. To achieve this, we need to 
--perform a self join to compare the table to itslef. In order to eliminate dupliacte records in the joined table, we shall use
--the where condition a.uniqueID != b.uniqueID, since the unique Id is unique for each record irrespective of wether the property
--address or parcelID is same.

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from sql_project.dbo.NashvilleHousing a
join sql_project.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and  a.[UniqueID ] != b.[UniqueID ]

select *
from sql_project.dbo.NashvilleHousing a
join sql_project.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and  a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null;

--Breaking the addresses down into individual columns (address, city)

--We will split the property addresses first using the substring and charindex methods.
--The sub string method returns part of a string based on the beginning and ending index provided. Charindex returns an integer
--specifying the index of an element of the array which is the result of a string split on a given delimiter. 
--All indexing starts from 1.

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select * 
from sql_project.dbo.NashvilleHousing

--Next, we shall split the owner addresses using the parsename method.
--Parsename only works on '.', hence we have to replace the ',' with '.' first.
--Another thing to note is that parsename returns index numbers from right to left, hence we need to fetch our
--substrings in reverse order.

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

select * 
from sql_project.dbo.NashvilleHousing

--Changing the 'Y' and 'N' to 'yes' and 'no' in SoldAsVacant

update NashvilleHousing
set SoldAsVacant =
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 end 
from sql_project.dbo.NashvilleHousing

select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from sql_project.dbo.NashvilleHousing
group by SoldAsVacant


--Removing Duplicates
--Row_Number() assigns an index number to a set of rows, for exampleif there are 3 duplicate rows, 
--they would be numbered 1,2 and 3. We create a partition with all the columns that cane be used to identify
--dupliacte rows and run the Row_Number() function over that.

with RowNumCTE as(
select *,
       ROW_NUMBER() over (partition by ParcelID,
				                       PropertyAddress,
				                       SalePrice,
				                       SaleDate,
				                       LegalReference
                              order by UniqueID)
							  as row_num
from sql_project.dbo.NashvilleHousing)

delete
from RowNumCTE
where row_num > 1


--Deleting Unused Columns

alter table sql_project.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

select *
from sql_project.dbo.NashvilleHousing








