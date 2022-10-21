function friendlyname = friendlychannelname(channelcode)     

% FRIENDLYCHANNELNAME  Return the textual name of a factor given its integer code.

globalconstants;

switch channelcode 
  case constants.cl.heart_rate
    friendlyname = 'Heart rate (bpm)';
  case constants.cl.systolic_blood_pressure
    friendlyname = 'Sys. blood pressure (mmHg)';  
  case constants.cl.diastolic_blood_pressure
    friendlyname = 'Dia. blood pressure (mmHg)';
  case constants.cl.mean_blood_pressure  
    friendlyname = 'Mean blood pressure (mmHg)';
  case constants.cl.saturation_O2
    friendlyname = 'SpO_2 (%)';
  case constants.cl.pulse_rate 
    friendlyname = 'Pulse rate (bpm)';
  case constants.cl.core_temp  
    friendlyname = 'Core temp. (\circC)';
  case constants.cl.peripheral_temp
    friendlyname = 'Peripheral temp. (\circC)';
  case constants.cl.incu_humidity 
    friendlyname = 'Incubator humidity (%)';
  case constants.cl.incu_temp
    friendlyname = 'Incubator temp. (\circC)';
  case constants.cl.trans_O2 
    friendlyname = 'Transcutaneous O_2 (kPa)';
  case constants.cl.trans_CO2 
    friendlyname = 'Transcutaneous CO_2 (kPa)';
  otherwise
    friendlyname = channelcode;
end
