use portfolioProject

go 

select * from [dbo].[NashvilleHousing] 

go 

alter table [dbo].[NashvilleHousing] 
add [SaleDateConv] date 

update [dbo].[NashvilleHousing] 
set [SaleDateConv] = try_convert(date,SaleDate) 


-- replace null values in property address with duplicated address

go 

update b
set b.[PropertyAddress] = isNull(b.[PropertyAddress],a.[PropertyAddress]) 
from [dbo].[NashvilleHousing] a join [dbo].[NashvilleHousing] b on a.[ParcelID] = b.[ParcelID]
and a.[UniqueID ] <> b.[UniqueID ]
where b.[PropertyAddress] is null

-- divide address to its three parts
go


alter table [dbo].[NashvilleHousing]
add propertySplitAddress nvarchar(255)

update [dbo].[NashvilleHousing]
set propertySplitAddress = substring([PropertyAddress], 1, CHARINDEX(',',[PropertyAddress])-1)

alter table [dbo].[NashvilleHousing]
add propertyCity nvarchar(255)

update [dbo].[NashvilleHousing]
set propertyCity = substring([PropertyAddress], CHARINDEX(',',[PropertyAddress])+1, LEN([PropertyAddress]))

alter table [dbo].[NashvilleHousing]
add ownerSplitAddress nvarchar(255)

alter table [dbo].[NashvilleHousing]
add ownerCity nvarchar(255)

alter table [dbo].[NashvilleHousing]
add ownerState nvarchar(255)

update [dbo].[NashvilleHousing]
set ownerSplitAddress = substring(OwnerAddress, 1, CHARINDEX(',',OwnerAddress)-1)

update [dbo].[NashvilleHousing]
set ownerCity = substring(address,1, CHARINDEX(',',address)-1)
from (
select substring(OwnerAddress, CHARINDEX(',',OwnerAddress)+1, LEN(OwnerAddress)) as  address
from [dbo].[NashvilleHousing]
) tb

update [dbo].[NashvilleHousing]
set ownerState = substring(address, CHARINDEX(',',address)+1, LEN(address))
from (
select substring(OwnerAddress, CHARINDEX(',',OwnerAddress)+1, LEN(OwnerAddress)) as  address
from [dbo].[NashvilleHousing]
) tb

select substring(address,1, CHARINDEX(',',address)-1) as city
,substring(address, CHARINDEX(',',address)+1, LEN(address)) as state
,substring(OwnerAddress, 1, CHARINDEX(',',OwnerAddress)-1) as address 
from (
select substring(OwnerAddress, CHARINDEX(',',OwnerAddress)+1, LEN(OwnerAddress)) as  address
,OwnerAddress
from [dbo].[NashvilleHousing]
) tb

-- soln 2 
select PARSENAME(REPLACE(OwnerAddress,',','.'),1),
 PARSENAME(REPLACE(OwnerAddress,',','.'),2),
 PARSENAME(REPLACE(OwnerAddress,',','.'),3)
from [dbo].[NashvilleHousing]

-- replace  N-->no , y -->yes

select case when [SoldAsVacant] = 'Y' then 'Yes'
 when [SoldAsVacant] = 'N' then 'No'
 else [SoldAsVacant] end ,[SoldAsVacant]
 from [dbo].[NashvilleHousing]

 select distinct [SoldAsVacant]  from [dbo].[NashvilleHousing]

 update [dbo].[NashvilleHousing]
 set [SoldAsVacant] =  case when [SoldAsVacant] = 'Y' then 'Yes'
 when [SoldAsVacant] = 'N' then 'No'
 else [SoldAsVacant] end 
 from [dbo].[NashvilleHousing]

 -- remove duplicates 

 with duplicated as (
 select ROW_NUMBER() over (partition by 
          [ParcelID],
[SaleDate],
[LegalReference],
[SalePrice],
[PropertyAddress]
order by [UniqueID]
 ) row_num
 from  [dbo].[NashvilleHousing]
 )

 delete from duplicated where row_num > 1 

 -- delete unused columns
 
 alter table [dbo].[NashvilleHousing]
 drop column [PropertyAddress],[OwnerAddress],[SaleDate],[TaxDistrict]


