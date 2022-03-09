Select *
From SQLProject..NashvilleHousing
order by 1,2
Go

--Change Y and N to "Yes" and "No" at "SolldAsVacant" field
--Alter table NashvilleHousing
Select distinct (SoldAsVacantConverted), count(SoldAsVacantConverted)
From NashvilleHousing
group by SoldAsVacantConverted

Select SoldAsVacant,
Case
When SoldAsVacant = 'N' Then 'No'
When SoldAsVacant = 'Y' Then 'Yes'
ELSE SoldAsVacant
End 
From NashvilleHousing
Go

Alter table NashvilleHousing
Add SoldAsVacantConverted NVARCHAR(255);

Update NashvilleHousing
Set SoldAsVacantConverted = Case
When SoldAsVacant = 'N' Then 'No'
When SoldAsVacant = 'Y' Then 'Yes'
ELSE SoldAsVacant
End 

--Stardardlize Date Format
Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert (Datetime, SaleDate)

Select SaleDate, SaleDateConverted, Convert (Datetime, SaleDate)
From NashvilleHousing

Select SaleDate, FORMAT (SaleDateConverted, 'dd-MM-yyyy') as "Date Converted"
From NashvilleHousing
Go

--Populate property Address data
Select *
From NashvilleHousing
Where PropertyAddress is null
Go

Select N.[UniqueID ],N.parcelID, N.PropertyAddress,N1.[UniqueID ],N1.parcelID, N1.PropertyAddress,ISNULL(N.PropertyAddress,N1.PropertyAddress) AS "converted", isnull(N1.PropertyAddress,N.PropertyAddress)
From NashvilleHousing N
Join NashvilleHousing N1 On N.ParcelID = N1.ParcelID And  N.[UniqueID ] <>N1.[UniqueID ]
Where N.PropertyAddress is null or N1.PropertyAddress is null
Go

Alter table N
Add PropertyAddressConverted Nvarchar(255)

Update N
Set PropertyAddressConverted = ISNULL(N.PropertyAddress,N1.PropertyAddress)
From NashvilleHousing N
Join NashvilleHousing N1 On N.ParcelID = N1.ParcelID And  N.[UniqueID ] <>N1.[UniqueID ]
Where N.PropertyAddress is null 

Update N1
Set PropertyAddressConverted = ISNULL(N1.PropertyAddress,N.PropertyAddress)
From NashvilleHousing N
Join NashvilleHousing N1 On N.ParcelID = N1.ParcelID And  N.[UniqueID ] <>N1.[UniqueID ]
Where N1.PropertyAddress is null 

Update N1
Set PropertyAddressConverted = ISNULL(N1.PropertyAddressConverted,N.PropertyAddress)
From NashvilleHousing N
Join NashvilleHousing N1 On N.[UniqueID ] = N1.[UniqueID ]
Where N1.PropertyAddressConverted is null 
Go

--Bkeaking out PropertyAddress into individual columns (Address, city, state)
Select substring(PropertyAddress,1, charindex(',',PropertyAddress)-1)
From NashvilleHousing

Select substring(PropertyAddress, charindex(',',PropertyAddress)+1, len(PropertyAddress))
From NashvilleHousing

ALter table NashvilleHousing
Add Address nvarchar(255)

ALter table NashvilleHousing
Add city nvarchar(255)

Update NashvilleHousing
Set Address = substring(PropertyAddress,1, charindex(',',PropertyAddress)-1)

Update NashvilleHousing
Set city = substring(PropertyAddress, charindex(',',PropertyAddress)+1, len(PropertyAddress))

sp_rename 'NashvilleHousing.Address', 'splitaddress','COLUMN';
sp_rename 'NashvilleHousing.city', 'splitcity','COLUMN';

Select PropertyAddress, OwnerAddress
From NashvilleHousing

Select PARSENAME(replace(OwnerAddress,',','.'),1)
From NashvilleHousing

ALter table NashvilleHousing
Add splitatate nvarchar(255);

Update NashvilleHousing
Set splitatate = PARSENAME(replace(OwnerAddress,',','.'),1)
Go

--Remove duplicates
With #TempNashvilleHousing as
(
Select *, ROW_NUMBER() over (partition by parcelID, SaleDate, LegalReference, OwnerName, PropertyAddress, SalePrice
							ORDER BY 
							UniqueID) Row_num
From NashvilleHousing
--order by parcelID
)
--Delete  from #TempNashvilleHousing
--where Row_num >= 2
Select * from #TempNashvilleHousing
where Row_num >= 2
Go

--Delete unused column
Alter table NashvilleHousing
Drop COLUMN PropertyAddress, TaxDistrict, OwnerAddress


