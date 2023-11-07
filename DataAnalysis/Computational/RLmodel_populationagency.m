function RLmodel_populationagency(dataset)
    
    global invest reward k
    
    df = readtable(dataset);
    data = table2array(df);
    population_agency = unique(data(:,5));
    
    k = 11;
    resultMatr = [];
    paramMat = [];
    for agency=1:length(population_agency) 
        popdata = data(data(:,5) == population_agency(agency),:);  % extract data of the subj
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        invest = popdata(:,8); % Money trusted is column 8
        reward = popdata(:,9); % Partner return is column 9
        for alpha = 0:0.3:1    % initial value of estimation for learning rate
            for beta = 0:2:6  % initial value of estimation for inverse temperature
                
                % finds the minimum. [x1,x2] is initial estimate
                % x is the solution. fval is the value of the function
                options = optimset('MaxIter', 100000, 'MaxFunEvals', 100000);
                [x,fval] = fminsearch(@TD_model, [alpha,beta], options);
                alpha_minimized = x(1);
                alpha_minimized = 1/(1+exp(alpha_minimized));
                beta_minimized = x(2);
                beta_minimized = exp(beta_minimized);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                resultMatr = [resultMatr;[population_agency(agency), alpha_minimized, beta_minimized, fval]];   % put these parameters in the resultMatr matrix
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        resultMat = resultMatr(resultMatr(:,2)>=0,:);
        resultMat = resultMat(resultMat(:,2)<=1,:);
        resultMat = resultMat(resultMat(:,3)>=0,:);
        fvals = resultMat(:,4);
        [row, col] = find(min(abs(fvals)));
        if isempty(find(min(abs(fvals))))
            paramMat = resultMat;
        else
            LR=resultMat(row,2);   % gain learning rate
            IT=resultMat(row,3);   % gain inverse temperature
            LL=resultMat(row,4);   % gain log likelihood
            paramMat = [paramMat;[population_agency(agency), LR, IT, LL]];
        end
    end
    
    savename='RL_AgencyTrust_resultMatr_agency';
    save([savename,'.mat'],'resultMatr');
    savename='RL_AgencyTrust_resultMat_agency';
    save([savename,'.mat'],'resultMat');
    savename='RL_AgencyTrust_paramMat_agency';
    save([savename,'.mat'],'paramMat');

