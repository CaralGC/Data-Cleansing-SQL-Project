
--====================================================================================================================================

-- Standardize Date Format
-- The date format in the SaleDate column includes date and hour, we need only the date

ALTER TABLE 
    HousingData.dbo.NashvilleHousing     --To create a new column named "SaleDateConverted" in NashvilleHousing table
ADD 
    SaleDateConverted Date

UPDATE 
    HousingData.dbo.NashvilleHousing       -- In the new column it is assigned the SaleDate date
SET 
    SaleDateConverted = CONVERT(Date, SaleDate)

SELECT                       -- To view the values from the "SaleDateConverted" column
    SaleDateConverted
FROM 
    HousingData.dbo.NashvilleHousing


--====================================================================================================================================

-- Populate Property Address data
-- There are some null values in the PropertyAddress column, to fill the empty cells, we are going to look for the same ParcelID that has not empty PropertyAddress, copy the PropertyAddress and paste it in the empty one.


UPDATE      -- To fill the missing values and update the NashvilleHousing table
    a
SET 
    PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)   --if PropertyAddress in table a is empty for a given ParcelID, fill it with PropertyAddress in table b
FROM 
    HousingData.dbo.NashvilleHousing AS a
JOIN HousingData.dbo.NashvilleHousing AS b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE
    a.PropertyAddress is null



--====================================================================================================================================

-- Breaking out Address into Individual Columns (Address, City, State)
-- The column PropertyAddress information includes address and city, it's needed to be splitted into to more columns: PropertySplitAddress and PropertySplitCity


SELECT                              --To see how it works... PARSENAME works with '.' from right to left, REPLACE changes the ',' for '.' s PARSENAME can be used 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address, 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM 
    HousingData.dbo.NashvilleHousing


ALTER TABLE 
    HousingData.dbo.NashvilleHousing     
ADD                                       -- To create five more columns, one for owner address, one for city, one for state, one for property address and one for property city
    OwnerSplitAddress Nvarchar(255),
	  OwnerSplitCity Nvarchar(255),
	  OwnerSplitState Nvarchar(255),
	  PropertySplitAddress Nvarchar(255),
	  PropertySplitCity Nvarchar(255)
UPDATE 
    HousingData.dbo.NashvilleHousing       -- 
SET 
    OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),           --It takes the part 3 of OwnerAddress string, then it assigns the substring to OwnerSplitAddress 
    OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),              --It takes the part 2 of OwnerAddress string, then it assigns the substring to OwnerSplitCity                                                             
	  OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)				 --It takes the part 1 of OwnerAddress string, then it assigns the substring to OwnerSplitState											                
	  PropertySplitAddress = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2),
	  PropertySplitCity = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1)
SELECT 
    OwnerSplitAddress,
	  OwnerSplitCity,
	  OwnerSplitState,
	  PropertySplitAddress,
	  PropertySplitCity
FROM 
    HousingData.dbo.NashvilleHousing


--====================================================================================================================================

--Change 'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant column


UPDATE 
    HousingData.dbo.NashvilleHousing                            
SET SoldAsVacant = CASE
						 WHEN 
							  SoldAsVacant = 'Y' THEN 'Yes'    -- It looks for Y's in SoldAsVacant and then changes it for Yes
						 WHEN
							  SoldAsVacant = 'N' THEN 'No'     -- It looks for N's in SoldAsVacant and then changes it for No
						 ELSE
							  SoldAsVacant
						 END


--====================================================================================================================

-- Remove duplicates

WITH RowNumCTE AS(
	SELECT *,
	       ROW_NUMBER() OVER(                        --The ROW_NUMBER() function is used to generate the row numbers by partition
		   PARTITION BY                              --PARTITION BY is used to create partitions of rows based on multiple columns: ParcelID, PropertyAddress, SalePrice, SaleDate, and LegalReference. 
					   PropertyAddress,              --Rows with the same values in these columns will belong to the same partition.
		         ParcelID,
					   SalePrice,
					   SaleDate,
					   LegalReference
					   ORDER BY
					           UniqueID) AS row_num   
	FROM 
		HousingData.dbo.NashvilleHousing
		)
DELETE
FROM
    RowNumCTE
WHERE row_num > 1


--==============================================================================================================================================

-- Delete unused columns

ALTER TABLE
    HousingData.dbo.NashvilleHousing
DROP COLUMN
    OwnerAddress,
	  TaxDistrict,
	  PropertyAddress,
	  SaleDate

SELECT *
FROM 
    HousingData.dbo.NashvilleHousing
