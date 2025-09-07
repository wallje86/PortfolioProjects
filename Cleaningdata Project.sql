-- CLEANING DATA

SELECT * 
FROM housing_data;

-- changing datetime format to date only.

SELECT SALEDATE, DATE(SALEDATE)
FROM housing_data;

ALTER TABLE HOUSING_DATA
MODIFY SALEDATE DATE;

-- Populate property address data

SELECT *
FROM housing_data
-- where propertyaddress is null
order by parcelID;

Select a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, coalesce(a.propertyaddress, b.propertyaddress)
from housing_data  a
Join housing_data  b 
	on a.ParcelID = b.ParcelID and a.uq_id <> b.uq_id
where a.propertyaddress is null;

UPDATE housing_data a
left join housing_data b on a.parcelID = b.parcelID and a.uq_id <> b.uq_id 
set a.propertyaddress = coalesce(a.propertyaddress, b.propertyaddress)
WHERE a.propertyaddress is null;

-- breaking out Address into individual columns (address, city, state)

SELECT propertyaddress
from housing_data;

select 
SUBSTRING(propertyaddress, 1, LOCATE(',', PROPERTYADDRESS) -1) AS ADDRESS,
	SUBSTRING(propertyaddress, LOCATE(',', PROPERTYADDRESS) +2, Length(propertyaddress)) as City
from housing_data;

Alter table housing_data
add PropertySplitAddress Varchar(255);

Update housing_data
set PropertySplitAddress = SUBSTRING(propertyaddress, 1, LOCATE(',', PROPERTYADDRESS) -1);

Alter Table housing_data
add PropertysplitCity Varchar (255);

Update housing_data
SET PropertySplitCity = SUBSTRING(propertyaddress, LOCATE(',', PROPERTYADDRESS) +2, Length(propertyaddress));

Select * 
from housing_data;

-- seperate owner address to street, city, state.

SELECT owneraddress
from housing_data;

-- attempt to seperate street address from city/state

select 
SUBSTRING(owneraddress, 1, LOCATE(',', owneraddress) -1) AS Street,
	SUBSTRING(owneraddress, LOCATE(',', owneraddress) +2, Length(owneraddress)) as City
from housing_data;

-- seperate state code from city.

select 
SUBSTRING(owneraddress, 1, LOCATE(',', owneraddress) -1) AS Street,
	SUBSTRING(owneraddress, LOCATE(',', owneraddress) +2, locate(',', owneraddress, locate(',', owneraddress)+2) - (locate(',', owneraddress)+2)) as City
FROM housing_data;

-- Use cleaner text to seperate owner address to street address, city, and state

SELECT 
substring_index(substring_index(owneraddress, ',', 1), ',', -1) as Street,
substring_index(substring_index(owneraddress, ',', 2), ',', -1) as City,
substring_index(substring_index(owneraddress, ',', 3), ',', -1) as State
from housing_data;

-- Create new columns and add information to each column.

Alter table housing_data
add OwnerSplitStreet varchar(255);

update housing_data
set OwnerSplitStreet = substring_index(substring_index(owneraddress, ',', 1), ',', -1);

Alter table housing_data
add OwnerSplitCity varchar(255);

UPDATE housing_data
Set OwnerSplitCity = substring_index(substring_index(owneraddress, ',', 2), ',', -1);

Alter table housing_data
add OwnerSplitState varchar(5);

UPDATE housing_data
SET OwnerSplitState = substring_index(substring_index(owneraddress, ',', 3), ',', -1) ;

SELECT *
FROM housing_data;

-- Change Y and N to yes and no in sold as vacant

select distinct(SoldAsVacant), count(soldasvacant)
From housing_data
group by soldasvacant
order by 2;

select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
when SoldAsVacant = 'N' THEN 'No'
else SoldAsVacant
END
from housing_data;

UPDATE housing_data
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
when SoldAsVacant = 'N' THEN 'No'
else SoldAsVacant
END;

-- Delete unused Columns

SELECT *
FROM housing_data;

ALTER table housing_data
DROP COLUMN PropertyAddress, 
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict;

-- Moving column position and Names.

ALTER TABLE `portfolioproject`.`housing_data` 
CHANGE COLUMN `PropertySplitAddress` `PropertySplitAddress` VARCHAR(100) NULL DEFAULT NULL AFTER `LandUse`,
CHANGE COLUMN `PropertysplitCity` `PropertysplitCity` VARCHAR(100) NULL DEFAULT NULL AFTER `PropertySplitAddress`,
CHANGE COLUMN `OwnerSplitStreet` `OwnerSplitStreet` VARCHAR(100) NULL DEFAULT NULL AFTER `OwnerName`,
CHANGE COLUMN `OwnerSplitCity` `OwnerSplitCity` VARCHAR(100) NULL DEFAULT NULL AFTER `OwnerSplitStreet`,
CHANGE COLUMN `OwnerSplitState` `OwnerSplitState` VARCHAR(5) NULL DEFAULT NULL AFTER `OwnerSplitCity`;

ALTER TABLE housing_data
CHANGE COLUMN `PropertySplitAddress` `PropertyAddressStreet` VARCHAR(100) NULL DEFAULT NULL;

ALTER TABLE housing_data
CHANGE COLUMN `PropertyAddressStreet` `PropertyStreet` VARCHAR(100) NULL DEFAULT NULL,
CHANGE COLUMN `Propertysplitcity` `PropertyCity` VARCHAR(100) NULL DEFAULT NULL,
CHANGE COLUMN `Ownersplitstreet` `OwnerStreet` VARCHAR(100) NULL DEFAULT NULL,
CHANGE COLUMN `OwnerSplitCity` `OwnerCity` VARCHAR(100) NULL DEFAULT NULL,
CHANGE COLUMN `OwnerSplitState` `OwnerState` VARCHAR(100) NULL DEFAULT NULL;

SELECT *
FROM housing_data