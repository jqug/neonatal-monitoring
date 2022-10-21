%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%  Global experiment settings  %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

settings.evaluate.saveinferences = 0;
settings.xfactortype = constants.xfactortype.inflatedsystemcov;
switch computer
case 'GLNX86'
  constants.evaluation.outputdir = [cd '/output'];
case 'PCWIN'
  constants.evaluation.outputdir = [cd '\output'];
end
settings.projectormode = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Number of hidden dimensions in each factor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
constants.factors.bloodsample.nhiddendims      = 2;
constants.factors.handling.nhiddendims         = 0;
constants.factors.tcdisconnection.nhiddendims  = 3;
constants.factors.tcprecal.nhiddendims         = 2;
constants.factors.bradycardia.nhiddendims      = 0;
constants.factors.x.nhiddendims                = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Observed channels for each factor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
constants.factors.bloodsample.obschannels      = {...
                                                  constants.cl.systolic_blood_pressure...
                                                  constants.cl.diastolic_blood_pressure};

constants.factors.handling.obschannels         = {constants.cl.incu_humidity...
                                                  constants.cl.heart_rate...
                                                  constants.cl.systolic_blood_pressure...
                                                  constants.cl.diastolic_blood_pressure...
                                                  constants.cl.saturation_O2...
};

constants.factors.tcdisconnection.obschannels  = {constants.cl.core_temp...
                                                  constants.cl.incu_temp};

constants.factors.tcprecal.obschannels         = {constants.cl.trans_O2...
                                                  constants.cl.trans_CO2};

constants.factors.bradycardia.obschannels      = {constants.cl.heart_rate};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Normal dynamics for each observation channel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%constants.normaldynamics.heart_rate               = {constants.models.arima,2,1,0};
%constants.normaldynamics.systolic_blood_pressure  = {constants.models.arima,2,1,0};
%constants.normaldynamics.diastolic_blood_pressure = {constants.models.arima,2,1,0};
%constants.normaldynamics.mean_blood_pressure      = {constants.models.arima,2,1,0};
constants.normaldynamics.saturation_O2            = {constants.models.arima,1,0,0};
%constants.normaldynamics.pulse_rate               = {constants.models.arima,2,1,0};
constants.normaldynamics.core_temp                 = {constants.models.arima,1,1,0};
%constants.normaldynamics.peripheral_temp          = {constants.models.arima,2,1,0};
constants.normaldynamics.incu_humidity            = {constants.models.arima,1,0,0};
constants.normaldynamics.incu_temp                 = {constants.models.arima,1,1,0};
%constants.normaldynamics.trans_O2                 = {constants.models.arima,2,1,0};
%constants.normaldynamics.trans_CO2                = {constants.models.arima,2,1,0};

constants.normaldynamics.heart_rate               = {constants.models.relativear,2,0,1,1,100};
constants.normaldynamics.systolic_blood_pressure  = {constants.models.relativear,2,0,1,1,100};
constants.normaldynamics.diastolic_blood_pressure = {constants.models.relativear,2,0,1,1,100};
constants.normaldynamics.mean_blood_pressure      = {constants.models.relativear,2,0,1,1,600};
%constants.normaldynamics.saturation_O2            = {constants.models.relativear,2,0,1,1,600};
constants.normaldynamics.pulse_rate               = {constants.models.relativear,2,0,1,1,600};
%constants.normaldynamics.core_temp                = {constants.models.relativear,2,0,1,1,600};
constants.normaldynamics.peripheral_temp          = {constants.models.relativear,2,0,1,1,600};
%constants.normaldynamics.incu_humidity            = {constants.models.relativear,2,0,1,1,600};
%constants.normaldynamics.incu_temp                = {constants.models.relativear,2,0,1,1,600};
constants.normaldynamics.trans_O2                 = {constants.models.relativear,2,0,1,1,600};
constants.normaldynamics.trans_CO2                = {constants.models.relativear,2,0,1,1,600};


