# rooster

#Authentication
Ga naar Firestore console -> Authentication
geef mail adres en password = prefix + originalcode + suffix
return '$prefix${trainer.originalAccessCode}$suffix';
final String passwordPrefix = 'pwd';
final String passwordSuffix = '!678123';

En je moet ook handmatig original email aanmaken

#powershell
Set-ExecutionPolicy unrestricted