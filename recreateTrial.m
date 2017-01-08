function [lick,odorEvts]=recreateTrial
Tags={'EVT02','EVT03','EVT01';'EVT07','EVT08','EVT06';'EVT19','EVT20','EVT18'};

allEvts=cell(1,3);
for grp=1
    for evt=1:3
    t=PL2EventTs('Dual-8s-R105-1-32EVT1234-R107-33-64EVT6789-R106-65-96-EVT18-21-0908.pl2',Tags{grp,evt});
    allEvts{evt}=[repmat(evt,numel(t.Ts),1),t.Ts];
    end
end

odorEvts=sortrows([allEvts{1};allEvts{2}],2);
lick=allEvts{3};
  
    
end