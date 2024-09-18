IF (NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Core')) 
BEGIN
    EXEC ('CREATE SCHEMA [Core] GO')
END
IF (NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Core')) 
BEGIN
    EXEC ('CREATE SCHEMA [Supporting] GO')
END
IF (NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Core')) 
BEGIN
    EXEC ('CREATE SCHEMA [General] GO')
END

declare @rowCount int = 1000;
--create table
IF  NOT EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[General].[Users]') AND type in (N'U'))
BEGIN
Create table General.Users
(
    Id int,
	FirstName nvarchar(50) null,
	LastName nvarchar(50) null,
	UserName varchar(50) null,
	Mobile varchar(15) null,
	Email varchar(150) null,
	NationalNo varchar(20) null,
	BirthDate datetime null,
	SignupDate datetime null,
	constraint OK_User_Id primary key clustered (Id)
)
END

create table #firstName (ID int identity(1, 1), FirstName nvarchar(50));
create table #lastName(ID int identity(1, 1), LastName nvarchar(50));
DECLARE @json NVARCHAR(MAX);

set @json = (SELECT * FROM OPENROWSET (BULK 'C:\Users\AL1989\Desktop\FirstNames.txt', SINGLE_NCLOB) as Contents)
insert into #firstName with (TABLOCK) (FirstName) (select [FirstName] from OPENJSON(@json) with ([FirstName] Nvarchar(max) '$.name'))

set @json = (SELECT * FROM OPENROWSET (BULK 'C:\Users\AL1989\Desktop\LastNames.txt', SINGLE_NCLOB) as Contents)
insert into #lastName with (TABLOCK) (LastName) (select [LastName] from OPENJSON(@json) with ([LastName] Nvarchar(max) '$.name'))

--initial FirstName and LastName
while(@rowCount > 0)
begin
declare @fRand int = (select FLOOR(RAND() * 1701))
declare @lRand int = (select FLOOR(RAND() * 357))

If @fRand != 0 and @lRand != 0
   begin
	 insert into General.Users(FirstName, 
	                            LastName
								)values((SELECT top(1) [FirstName] FROM #firstName where ID = @fRand),
								        (SELECT top(1) [LastName] FROM #lastName where ID = @lRand))


	set @rowCount = @rowCount - 1
   end
end

declare @namesCount int = (select count(*) from General.Users)

while @namesCount > 0
begin
--begin: create username
declare @username nvarchar(300)
declare @word nvarchar(10)
declare @count int = (select COUNT(substring(a.b, v.number+1, 1)) from (select (select [FirstName] + [LastName] from General.Users ORDER BY FirstName OFFSET @namesCount ROWS FETCH NEXT 1 ROWS ONLY) b) a join master..spt_values v on v.number < len(a.b) where v.type = 'P' )
declare @counter int = 0
  while @counter < @count
  begin
  declare @name nvarchar(50) = (select [FirstName] + [LastName] from General.Users ORDER BY FirstName OFFSET @namesCount ROWS FETCH NEXT 1 ROWS ONLY)
	set @word = (select substring(a.b, v.number+1, 1) from (select @name b) a join master..spt_values v on v.number < len(a.b) where v.type = 'P'
	ORDER BY v.number
    OFFSET @counter ROWS   
    FETCH NEXT 1 ROWS ONLY)  
    SET @counter = @counter + 1

    select @word = CASE @word
    WHEN N'ا' THEN 'A'
    WHEN N'ب' THEN 'B'
    WHEN N'پ' THEN 'P'
	WHEN N'ت' THEN 'T'
	WHEN N'ث' THEN 'S'
	WHEN N'ج' THEN 'j'
	WHEN N'چ' THEN 'CH'
	WHEN N'ح' THEN 'H'
	WHEN N'خ' THEN 'KH'
	WHEN N'د' THEN 'D'
	WHEN N'ذ' THEN 'Z'
	WHEN N'س' THEN 'S'
	WHEN N'ش' THEN 'SH'
	WHEN N'ص' THEN 'S'
	WHEN N'ض' THEN 'Z'
	WHEN N'ط' THEN 'T'
	WHEN N'ظ' THEN 'Z'
	WHEN N'ع' THEN 'A'
	WHEN N'غ' THEN 'GH'
	WHEN N'ف' THEN 'F'
	WHEN N'ق' THEN 'GH'
	WHEN N'ک' THEN 'K'
	WHEN N'گ' THEN 'G'
	WHEN N'ل' THEN 'L'
	WHEN N'م' THEN 'M'
	WHEN N'ن' THEN 'N'
	WHEN N'و' THEN 'V'
	WHEN N'ه' THEN 'H'
	WHEN N'ی' THEN 'Y'
	WHEN N'آ' THEN 'A'
	WHEN N'ر' THEN 'R'
	WHEN N'ژ' THEN 'ZH'
	WHEN N'ز' THEN 'Z'
	WHEN N'َ' THEN 'A'
	WHEN N'ُ' THEN 'O'
	WHEN N'ِ' THEN 'E'
	WHEN N'ئ' THEN 'E'
	WHEN N' ' THEN ' '
	WHEN N'‌' THEN ' '
    ELSE 'Guess' 
    END

	set @username = (select Concat(@username, @word))
  end
  update General.Users set UserName = @username where [FirstName] + [LastName] = @name
  set @username = ''
  set @namesCount = @namesCount - 1
--end: create username
end

drop table #lastName;
drop table #firstName;
