function [pop, F]=sort_process(pop)


    [~, CDSO]=sort([pop.CrowdingDistance],'descend');
    pop=pop(CDSO);
    

    [~, RSO]=sort([pop.Rank]);
    pop=pop(RSO);
    

    Ranks=[pop.Rank];
    MaxRank=max(Ranks);
    F=cell(MaxRank,1);
    for r=1:MaxRank
        F{r}=find(Ranks==r);
    end

end