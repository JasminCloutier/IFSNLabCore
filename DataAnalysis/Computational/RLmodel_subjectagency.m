function RLmodel_subjectagency(dataset)
    
    global invest reward k
    
    df = readtable(dataset);
    data = table2array(df);
    subjects = unique(data(:,2));
    
    k = 11;

    resultMatr = [];
    paramMat = [];
    for subj=1:5%length(subjects) 
        subdata = data(data(:,2) == subjects(subj),:);  % extract data of the subj
        sub_agency = unique(subdata(:,5));
        for agency=1:length(sub_agency)
            subagencydata = subdata(subdata(:,5) == sub_agency(agency),:); % extract data of subject by agency
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            invest = subagencydata(:,8); % Money trusted is column 8
            reward = subagencydata(:,9); % Partner return is column 9
            for alpha = 0:0.3:1    % initial value of estimation for learning rate
                for zeta = 0:2:6  % initial value of estimation for inverse temperature
                    
                    % finds the minimum. [x1,x2] is initial estimate
                    % x is the solution. fval is the value of the function
                    options = optimset('MaxIter', 100000, 'MaxFunEvals', 100000);
                    [x,fval] = fminsearch(@TD_model, [alpha,zeta], options);
                    alpha_minimized = x(1);
                    zeta_minimized = x(2);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    resultMatr = [resultMatr;[subjects(subj), sub_agency(agency), alpha_minimized, zeta_minimized, fval]];   % put these parameters in the resultMatr matrix
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            resultMat = resultMatr(resultMatr(:,3)>=0,:);
            resultMat = resultMat(resultMat(:,4)>=0,:);
            fvals = resultMat(:,5);
            [row, col] = find(min(abs(fvals)));
            LR=resultMat(row,3);   % gain learning rate
            IT=resultMat(row,4);   % gain inverse temperature
            LL=resultMat(row,5);   % gain log likelihood
            paramMat = [paramMat;[subjects(subj), sub_agency(agency), LR, IT, LL]];
        end
    end
    savename='RL_AgencyTrust_resultMatr_subagency';
    save([savename,'.mat'],'resultMatr');
    savename='RL_AgencyTrust_resultMat_subagency';
    save([savename,'.mat'],'resultMat');
    savename='RL_AgencyTrust_paramMat_subagency';
    save([savename,'.mat'],'paramMat');
