classdef uDMOEA < ALGORITHM
 % <multi> <real/integer/label/binary/permutation> <constrained/none> <dynamic>
 % zeta --- 0.2 --- Ratio of change response solutions
 % N --- 20 --- Population size (default)
 % N --- 100 --- Population size

    methods
        function main(Algorithm,Problem)
            %% Parameter setting
            [Problem.N, zeta] = Algorithm.ParameterSet(20, 0.2);
            %[Problem.N, zeta] = Algorithm.ParameterSet(100, 0.2);

            
            % Reset the number of saved populations (only for dynamic optimization)
            Algorithm.save = sign(Algorithm.save)*inf;

            %% Generate random population
            Population = Problem.Initialization();
            Fitness    = CalFitness(Population.objs);
            % Archive for storing all populations before each change
            AllPop = [];

            %% Optimization
            while Algorithm.NotTerminated(Population)
                if Changed(Problem,Population)
                    % Save the population before the change
                    AllPop = [AllPop,Population];
                    % React to the change
                    [Population,Fitness] = ChangeResponse(Problem,Population,zeta);
                end
                MatingPool = TournamentSelection(2,Problem.N,Fitness);
                Offspring  = OperatorGA(Problem,Population(MatingPool));
                [Population,Fitness] = KNN([Population,Offspring],Problem.N);
                if Problem.FE >= Problem.maxFE
                    % Return all populations
                    Population = [AllPop,Population];
                    [~,rank]   = sort(Population.adds(zeros(length(Population),1)));
                    Population = Population(rank);
                end
            end
        end
    end
end                   