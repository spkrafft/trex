function [roi_name,roi_source,roi_int,roi_ext] = add_subvolumes(h)
%%
roi_name = cell(0);
roi_source = cell(0);
roi_int = cell(0);
roi_ext = cell(0);

if isempty(h.export.roi_source)
    msgbox('Select a source roi!')
    return
end

source = h.export.roi_source;

roi_name{end+1,1} = [source,'_Superior_50%'];
roi_source{end+1,1} = [source,' (Subvolume: Superior_50%)'];
roi_int{end+1,1} = [];
roi_ext{end+1,1} = [];

roi_name{end+1,1} = [source,'_Inferior_50%'];
roi_source{end+1,1} = [source,' (Subvolume: Inferior_50%)'];
roi_int{end+1,1} = [];
roi_ext{end+1,1} = [];

roi_name{end+1,1} = [source,'_Distal_50%'];
roi_source{end+1,1} = [source,' (Subvolume: Distal_50%)'];
roi_int{end+1,1} = [];
roi_ext{end+1,1} = [];

roi_name{end+1,1} = [source,'_Central_50%'];
roi_source{end+1,1} = [source,' (Subvolume: Central_50%)'];
roi_int{end+1,1} = [];
roi_ext{end+1,1} = [];

roi_name{end+1,1} = [source,'_Anterior_50%'];
roi_source{end+1,1} = [source,' (Subvolume: Anterior_50%)'];
roi_int{end+1,1} = [];
roi_ext{end+1,1} = [];

roi_name{end+1,1} = [source,'_Posterior_50%'];
roi_source{end+1,1} = [source,' (Subvolume: Posterior_50%)'];
roi_int{end+1,1} = [];
roi_ext{end+1,1} = [];

roi_name{end+1,1} = [source,'_Inter_SDA_50%'];
roi_source{end+1,1} = [source,' (Subvolume: Inter_SDA_50%)'];
roi_int{end+1,1} = [];
roi_ext{end+1,1} = [];

roi_name{end+1,1} = [source,'_Inter_SDP_50%'];
roi_source{end+1,1} = [source,' (Subvolume: Inter_SDP_50%)'];
roi_int{end+1,1} = [];
roi_ext{end+1,1} = [];

roi_name{end+1,1} = [source,'_Inter_SCA_50%'];
roi_source{end+1,1} = [source,' (Subvolume: Inter_SCA_50%)'];
roi_int{end+1,1} = [];
roi_ext{end+1,1} = [];

roi_name{end+1,1} = [source,'_Inter_SCP_50%'];
roi_source{end+1,1} = [source,' (Subvolume: Inter_SCP_50%)'];
roi_int{end+1,1} = [];
roi_ext{end+1,1} = [];

roi_name{end+1,1} = [source,'_Inter_IDA_50%'];
roi_source{end+1,1} = [source,' (Subvolume: Inter_IDA_50%)'];
roi_int{end+1,1} = [];
roi_ext{end+1,1} = [];

roi_name{end+1,1} = [source,'_Inter_IDP_50%'];
roi_source{end+1,1} = [source,' (Subvolume: Inter_IDP_50%)'];
roi_int{end+1,1} = [];
roi_ext{end+1,1} = [];

roi_name{end+1,1} = [source,'_Inter_ICA_50%'];
roi_source{end+1,1} = [source,' (Subvolume: Inter_ICA_50%)'];
roi_int{end+1,1} = [];
roi_ext{end+1,1} = [];

roi_name{end+1,1} = [source,'_Inter_ICP_50%'];
roi_source{end+1,1} = [source,' (Subvolume: Inter_ICP_50%)'];
roi_int{end+1,1} = [];
roi_ext{end+1,1} = [];
 
%%
clearvars -except roi_name roi_source roi_int roi_ext
        