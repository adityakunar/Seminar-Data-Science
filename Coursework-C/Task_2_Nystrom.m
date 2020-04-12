clear
clc
%read in the data in matlab.
X = readtable('./data/iris.data.csv');

T = X( :, 1:4);

labels = X(:,5);

labels =table2array(labels);

data = table2array(T);

L = [1,2,3]; % selected features

[PCA, Newdata] = calc_mapping(L, data);

disp("dot product = " + dot(PCA(:,1),PCA(:,2)))

ReducedData = Newdata * PCA;

corrcoef(ReducedData)

var(ReducedData)/sum(var(ReducedData));

plot_2d_scatter(ReducedData, labels, labels, "Nystrom Iris")

%=================================================================================

function plot_2d_scatter(x, lab, orig_lab, t)
    classes = unique(orig_lab);
    num_classes = size(classes, 1);
    
    colmap = lines(num_classes);
    width=1000;
    height=800;
    
    figure();
    c = [];
    for i = 1:num_classes
        if isa(lab, 'double') || isa(lab, 'int')
            indexes = find(lab == classes(i)); % type double
        else
            indexes = find(strcmp(lab, classes(i))); % type cell
        end
        
        if size(indexes,1) <= 0
            continue
        end
        

        scatter(x(indexes,1), x(indexes,2),[], colmap(i,:), 'DisplayName', string(classes(i)), 'MarkerFaceAlpha',.4,'MarkerEdgeAlpha',.6);
        hold on
        c = mean(x(indexes, :));
        text(c(1), c(2), string(classes(i)),'FontSize', 16 )
        hold on
    end
    
    legend()
    set(gcf,'position',[0,0,width,height]);
    title(t);
end


function [PCA, Newdata] = calc_mapping(L, data)
    l=size(L,2);


    Index = 1 : size(data,2);

    FirstL = data(:,L);

    RMI = setdiff(Index,L);

    RestMat = data(:,RMI);

    Newdata = [FirstL RestMat];

    Newdata = Newdata - mean(Newdata,1);

    m = size(data,1);

    NyCov = (Newdata' * Newdata(:,1:l))./(m-1); %the natural way to compute it. 

    NyCovA = NyCov(1:l,1:l);

    NyCovB = NyCov((l+1):end,1:l);

    [eigvecA, eigvalA] =eig(NyCovA,'matrix');
    %computing the indices of the eigen values in decreasing order.
    [d,ind] = sort(diag(eigvalA),'descend');
    %sorting eigen values as per the computed indices.
    eigvalsorted = eigvalA(ind,ind);
    % similarly sorting the eigen vectors as per the computed indices.
    eigvecsorted = eigvecA(:,ind);

    U_A = eigvecsorted;

    U_B = NyCovB * U_A * inv(eigvalsorted); 

    PCA_Mat = [U_A; U_B];


    PCA = zeros(size(PCA_Mat));

    k = 1;   
    for a = L
        PCA(a,:)=PCA_Mat(k,:)/norm(PCA_Mat(k,:));
        k=k+1;
    end

    for a = RMI
        PCA(a,:)=PCA_Mat(k,:)/norm(PCA_Mat(k,:));
        k=k+1;
    end
end