function friendlyname = friendlyfactorname(factorcode)     

% FRIENDLYFACTORNAME  Return the textual name of a factor given its integer code.

globalconstants;

switch factorcode
  case constants.factors.bloodsample.id
    friendlyname = 'Blood sample';
  case constants.factors.handling.id     
    friendlyname = 'Handling';
  case constants.factors.tcdisconnection.id
    friendlyname = 'Core temp. disconnection';
  case constants.factors.tcprecal.id       
    friendlyname = 'TCP recalibration';
  case constants.factors.bradycardia.id  
    friendlyname = 'Bradycardia';
  case constants.factors.x.id 
    friendlyname = 'X';
  otherwise
    friendlyname = ['Unknown factor (' num2str(factorcode) ')'];
end 
