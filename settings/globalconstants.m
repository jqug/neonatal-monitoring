%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inference method identifiers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
constants.inference.adf                        = 1;
constants.inference.adf_constrainedtrans       = 2;
constants.inference.rbpf_nlow                  = 3;                     
constants.inference.rbpf_nhigh                 = 4;   
constants.inference.fhmm                       = 5; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Observation channel identifiers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
constants.cl.heart_rate                        = 'heart_rate';
constants.cl.systolic_blood_pressure           = 'systolic_blood_pressure';
constants.cl.diastolic_blood_pressure          = 'diastolic_blood_pressure';
constants.cl.mean_blood_pressure               = 'mean_blood_pressure';
constants.cl.saturation_O2                     = 'saturation_O2';
constants.cl.pulse_rate                        = 'pulse_rate';
constants.cl.core_temp                         = 'core_temp';
constants.cl.peripheral_temp                   = 'peripheral_temp';
constants.cl.incu_humidity                     = 'incu_humidity';
constants.cl.incu_temp                         = 'incu_temp';
constants.cl.trans_O2                          = 'trans_O2';
constants.cl.trans_CO2                         = 'trans_CO2';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Factor identifiers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
constants.factors.bloodsample.id               = 1;
constants.factors.handling.id                  = 2;
constants.factors.tcdisconnection.id           = 3;
constants.factors.tcprecal.id                  = 4;
constants.factors.bradycardia.id               = 5;
constants.factors.x.id                         = 6;
constants.factors.highestfactorid              = 6;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% X-factor model types
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
constants.xfactortype.inflatedsystemcov        = 1; % default
constants.xfactortype.inflatedobscov           = 2; % inflated observation noise
constants.xfactortype.whitenoise               = 3; % white noise process


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Basic dynamical models
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
constants.models.ar = 1;
constants.models.arima = 2;
constants.models.relativear = 3;
