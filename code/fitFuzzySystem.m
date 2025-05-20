function outputFIS = fitFuzzySystem(table_x, table_y, fis_options)
    x = table_x{:,:};
    y = table_y{:,:};
    
    fisin = genfis(x,y,fis_options);

    % figure;
    % for i = 1:numel(fisin.Inputs)
    %     subplot(numel(fisin.Inputs), 1, i);
    %     plotmf(fisin, 'input', i);
    %     title(['Input ' num2str(i) ' MF']);
    % end
    % 
    % plotfis(fisin)
    
    % Obtain the tunable settings of inputs, outputs, and rules of the fuzzy inference system.
    [in,out,~] = getTunableSettings(fisin);
    opt = tunefisOptions("Method","anfis");
    opt.MethodOptions.EpochNumber = 100;
    
    % Tune the membership function parameters with "anfis".
    [outputFIS,~] = tunefis(fisin,[in;out],x,y,opt);    
    display(outputFIS);
end
