#include "mex.hpp"
#include "mexAdapter.hpp"

#include <algorithm>
#include <random>
#include <vector>
#include <chrono>
#include <utility>

#define INF (0x3f3f3f3f)

using namespace std;
using matlab::mex::ArgumentList;

class MexFunction : public matlab::mex::Function {
public:
    void operator() (ArgumentList outputs, ArgumentList inputs) {
        const int nrMissions = inputs[ 0 ][ 0 ];
        const int nodes = inputs[ 1 ][ 0 ];
        const int flight_time = inputs[ 2 ][ 0 ];
        
        vector <pair<int, int>> missions;
        
        for (int i = 0; i < nrMissions; i++) {
            int x = inputs[ 3 ][ i ][ 0 ];
            int y = inputs[ 3 ][ i ][ 1 ];
            
            missions.push_back({ x, y });
        }
        
        vector<vector<int>> dist(nodes, vector<int>(nodes));
        for (int i = 0; i < nodes; i++) {
            for (int j = 0; j < nodes; j++) {
                dist[ i ][ j ] = inputs[ 4 ][ i ][ j ];
            }
        }
        
        vector <int> gcDistance;
        for (int i = 0; i < nodes; i++)
            gcDistance.push_back(inputs[ 5 ][ i ]);
        
        vector <vector<int>> sol = shuffle_matching(missions, dist, gcDistance, flight_time);
        
        matlab::data::ArrayFactory factory;
        for (int i = 0; i < sol.size(); i++) {
            outputs[ i ] = factory.createArray<int32_t> ({1, sol[ i ].size()}, sol[ i ].data(), sol[ i ].data() + sol[ i ].size());
        }
    }
    
    int partitionMissions(vector <int> &trial, vector<pair<int, int>> &missions, int maxFlightTime, vector<vector<int>> &dist, vector<int> &gcDistance, vector<vector<int>> &partitionTrial) {
      partitionTrial.clear();

      int idx = 0, crtTime, totalTime = 0;
      vector <int> crt;

      int firstPickup = missions[trial[idx]].first;
      int firstDelivery = missions[trial[idx]].second;

      crtTime = gcDistance[firstPickup] + dist[firstPickup][firstDelivery] + gcDistance[firstDelivery];
      crt.push_back(idx);
      idx++;
      while (idx < trial.size()) {
        int lastDelivery = missions[trial[idx-1]].second;
        int pickup = missions[trial[idx]].first;
        int delivery = missions[trial[idx]].second;

        int newTime = crtTime - gcDistance[lastDelivery] + dist[lastDelivery][pickup] + dist[pickup][delivery] + gcDistance[delivery];
        if (newTime <= maxFlightTime) {
          crtTime = newTime;
          crt.push_back(idx);
        } else {
          partitionTrial.push_back(crt);
          crt.clear();
          totalTime += crtTime;

          crtTime = gcDistance[pickup] + dist[pickup][delivery] + gcDistance[delivery];
          crt.push_back(idx);
        }

        idx++;
      }

      totalTime += crtTime;
      partitionTrial.push_back(crt);

      return totalTime;
    }

    vector<vector<int>> shuffle_matching(vector<pair<int, int>> &missions, vector<vector<int>> &dist, vector<int> &gcDistance, int maxFlightTime) {
      vector<vector<int>> best;
      vector<vector<int>> partitionTrial(missions.size());

      const int TRIALS = 100;
      int bestTotalTime = INF;
      unsigned seed = std::chrono::system_clock::now().time_since_epoch().count();
      std::default_random_engine e(seed);


      vector<int> trial;
      for (int i = 0; i < missions.size(); i++) {
        trial.push_back( i );
      }

      for (int i = 0; i < TRIALS; i++) {
        shuffle(trial.begin(), trial.end(), e);
        int trialTime = partitionMissions(trial, missions, maxFlightTime, dist, gcDistance, partitionTrial);

        if (trialTime < bestTotalTime) {
          bestTotalTime = trialTime;
          best = partitionTrial;
        }
      }

      return best;
    }

};
    