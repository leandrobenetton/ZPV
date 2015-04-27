if exists(select 1 from CountryPack where [Name] = 'PDV')
begin
	update CountryPack
		set [Version] = 'SL 9.00.20 2015-04-23' 
	where [Name] = 'PDV'
end
else
begin
	insert into CountryPack(
		Name,
		[Option],
		[Description],
		[Version])
	values(
		'PDV',
		'L',
		'Retail Localization',
		'SL 9.00.20 2015-04-23')
end
